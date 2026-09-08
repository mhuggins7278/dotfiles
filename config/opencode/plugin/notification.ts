import type { Plugin } from "@opencode-ai/plugin";

export const NotificationPlugin: Plugin = async ({
  project,
  client,
  $,
  directory,
  worktree,
}) => {
  const notifiedPermissionSessions = new Set<string>();

  type TmuxNotificationTarget = {
    clientTty: string;
    activeSessionName: string;
    targetSessionName: string | null;
    targetWindowId: string | null;
    targetPaneId: string | null;
    tmuxPath: string;
  };

  const isGhosttyFocused = async (): Promise<boolean> => {
    try {
      const result =
        await $`osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true'`.text();
      return result.trim() === "ghostty";
    } catch {
      return false;
    }
  };

  const getNotificationTarget =
    async (): Promise<TmuxNotificationTarget | null> => {
      try {
        const tmuxPath = (await $`command -v tmux`.text()).trim();
        const processTty = (
          await $`ps -o tty= -p ${process.pid}`.text()
        ).trim();
        // tmux emits \t literally in -F formats, so use a control separator.
        const fieldSeparator = "\u001f";
        const paneFormat = `#{pane_tty}${fieldSeparator}#{session_name}${fieldSeparator}#{window_id}${fieldSeparator}#{pane_id}`;
        const paneResult =
          await $`tmux list-panes -a -F ${paneFormat} 2>/dev/null`.text();
        const targetPane = paneResult
          .trim()
          .split("\n")
          .map((line) => {
            const [paneTty, sessionName, windowId, paneId] =
              line.split(fieldSeparator);
            return { paneTty, sessionName, windowId, paneId };
          })
          .find(({ paneTty }) => paneTty === `/dev/${processTty}`);

        const sessionFormat = `#{session_name}${fieldSeparator}#{session_path}`;
        const sessionResult =
          await $`tmux list-sessions -F ${sessionFormat} 2>/dev/null`.text();
        const sessions = sessionResult
          .trim()
          .split("\n")
          .map((line) => line.split(fieldSeparator))
          .filter(([sessionName, sessionPath]) => sessionName && sessionPath);
        const directoryName = directory.split("/").pop() || "";
        const normalizedDirectoryName = directoryName.replace(/\./g, "_");
        const targetSession =
          sessions.find(([, sessionPath]) => sessionPath === directory) ||
          sessions.find(
            ([sessionName]) => sessionName === normalizedDirectoryName,
          );
        const targetSessionName =
          targetPane?.sessionName || targetSession?.[0] || null;

        // client_activity is the last input timestamp, not the client being
        // viewed. Prefer the client displaying this pane or target session.
        const clientFormat = `#{client_activity}${fieldSeparator}#{client_tty}${fieldSeparator}#{session_name}${fieldSeparator}#{client_flags}${fieldSeparator}#{pane_id}`;
        const clientResult =
          await $`tmux list-clients -F ${clientFormat} 2>/dev/null`.text();
        const clients = clientResult
          .trim()
          .split("\n")
          .map((line) => {
            const [activity, clientTty, sessionName, flags, paneId] =
              line.split(fieldSeparator);
            return { activity, clientTty, sessionName, flags, paneId };
          })
          .filter(({ clientTty, sessionName }) => clientTty && sessionName)
          .sort((a, b) => Number(b.activity) - Number(a.activity));
        const client =
          clients.find(({ paneId }) => paneId === targetPane?.paneId) ||
          clients.find(
            ({ sessionName }) => sessionName === targetSessionName,
          ) ||
          clients.find(({ flags }) => flags?.includes("focused")) ||
          clients[0];
        const { clientTty, sessionName: activeSessionName } = client || {};

        if (!clientTty || !activeSessionName || !tmuxPath) return null;

        return {
          clientTty,
          activeSessionName,
          targetSessionName,
          targetWindowId: targetPane?.windowId || null,
          targetPaneId: targetPane?.paneId || null,
          tmuxPath,
        };
      } catch {
        return null;
      }
    };

  const getSessionTitle = async (sessionID: string): Promise<string> => {
    try {
      const session = await client.session.get({ path: { id: sessionID } });
      return session.data?.title || "OpenCode";
    } catch {
      return "OpenCode";
    }
  };

  const isSubagentSession = async (sessionID: string): Promise<boolean> => {
    try {
      const session = await client.session.get({ path: { id: sessionID } });
      return Boolean(session.data?.parentID);
    } catch {
      return false;
    }
  };

  const escapeAppleScriptString = (value: string): string =>
    value.replace(/\\/g, "\\\\").replace(/"/g, '\\"').replace(/\r?\n/g, " ");

  const shellQuote = (value: string): string =>
    `'${value.replace(/'/g, "'\\''")}'`;

  const notify = async (
    message: string,
    subtitle: string,
    target: TmuxNotificationTarget | null,
  ): Promise<void> => {
    const projectName = directory.split("/").pop() || "opencode";
    let terminalNotifier: string;

    try {
      terminalNotifier = (await $`command -v terminal-notifier`.text()).trim();
    } catch {
      terminalNotifier = "";
    }

    if (terminalNotifier) {
      const tmuxCommands = target?.targetSessionName
        ? [
            `${shellQuote(target.tmuxPath)} switch-client -c ${shellQuote(target.clientTty)} -t ${shellQuote(`=${target.targetSessionName}`)}`,
            target.targetWindowId
              ? `${shellQuote(target.tmuxPath)} select-window -t ${shellQuote(target.targetWindowId)}`
              : "",
            target.targetPaneId
              ? `${shellQuote(target.tmuxPath)} select-pane -t ${shellQuote(target.targetPaneId)}`
              : "",
          ]
            .filter(Boolean)
            .join("; ")
        : `${shellQuote("/usr/bin/open")} -b com.mitchellh.ghostty`;
      const clickCommand = target?.targetSessionName
        ? `${tmuxCommands}; ${shellQuote("/usr/bin/open")} -b com.mitchellh.ghostty`
        : tmuxCommands;
      await $`${terminalNotifier} -title ${projectName} -subtitle ${subtitle} -message ${message} -sound Hero -execute ${clickCommand}`
        .quiet()
        .nothrow();
      return;
    }

    // Keep notifications working until terminal-notifier is installed.
    const script = `display notification "${escapeAppleScriptString(message)}" with title "${escapeAppleScriptString(projectName)}" subtitle "${escapeAppleScriptString(subtitle)}" sound name "Hero"`;
    await $`osascript -e ${script}`.quiet().nothrow();
  };

  const shouldNotify = async (
    target: TmuxNotificationTarget | null,
  ): Promise<boolean> => {
    if (!(await isGhosttyFocused())) return true;
    return !target || target.activeSessionName !== target.targetSessionName;
  };

  return {
    event: async ({ event }) => {
      if (event.type === "permission.replied") {
        notifiedPermissionSessions.delete(event.properties.sessionID);
        return;
      }

      if (
        event.type !== "session.idle" &&
        event.type !== "session.error" &&
        event.type !== "permission.asked"
      )
        return;

      const notificationTarget = await getNotificationTarget();
      if (!(await shouldNotify(notificationTarget))) return;

      if (event.type === "permission.asked") {
        if (notifiedPermissionSessions.has(event.properties.sessionID)) return;
        notifiedPermissionSessions.add(event.properties.sessionID);
        await notify(
          "OpenCode needs permission",
          "Action required",
          notificationTarget,
        );
        return;
      }

      const sessionID = event.properties.sessionID;
      if (await isSubagentSession(sessionID)) return;

      const sessionTitle = await getSessionTitle(sessionID);
      if (event.type === "session.error") {
        await notify(
          `OpenCode encountered an error: ${sessionTitle}`,
          "Needs attention",
          notificationTarget,
        );
        return;
      }

      await notify(
        `OpenCode is ready: ${sessionTitle}`,
        "Ready to continue",
        notificationTarget,
      );
    },
  };
};
