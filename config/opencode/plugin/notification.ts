import type { Plugin } from "@opencode-ai/plugin";

export const NotificationPlugin: Plugin = async ({
  project,
  client,
  $,
  directory,
  worktree,
}) => {
  const notifiedPermissionSessions = new Set<string>();

  const isGhosttyFocused = async (): Promise<boolean> => {
    try {
      const result =
        await $`osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true'`.text();
      return result.trim() === "ghostty";
    } catch {
      return false;
    }
  };

  const getActiveGhosttyTmuxSession = async (): Promise<string | null> => {
    try {
      // Get the currently active tmux client (the one the user is viewing)
      // This finds the most recently active attached session
      const result =
        await $`tmux list-clients -F '#{client_activity}:#{session_name}' 2>/dev/null | sort -rn | head -1 | cut -d: -f2`.text();
      const sessionName = result.trim();

      if (sessionName) {
        return sessionName;
      }

      return null;
    } catch {
      return null;
    }
  };

  const tmuxSessionMatchesDirectory = async (): Promise<boolean> => {
    const sessionName = await getActiveGhosttyTmuxSession();
    if (!sessionName) {
      // If we can't detect a tmux session, don't suppress notifications
      return false;
    }

    const directoryName = directory.split("/").pop() || "";
    // sesh converts dots to underscores when creating session names
    const normalizedDirectoryName = directoryName.replace(/\./g, "_");

    return sessionName === normalizedDirectoryName;
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

  const notify = async (message: string, subtitle: string): Promise<void> => {
    const projectName = directory.split("/").pop() || "opencode";
    const script = `display notification "${escapeAppleScriptString(message)}" with title "${escapeAppleScriptString(projectName)}" subtitle "${escapeAppleScriptString(subtitle)}" sound name "Hero"`;
    await $`osascript -e ${script}`.quiet().nothrow();
  };

  const shouldNotify = async (): Promise<boolean> => {
    if (!(await isGhosttyFocused())) return true;
    return !(await tmuxSessionMatchesDirectory());
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

      if (!(await shouldNotify())) return;

      if (event.type === "permission.asked") {
        if (notifiedPermissionSessions.has(event.properties.sessionID)) return;
        notifiedPermissionSessions.add(event.properties.sessionID);
        await notify("OpenCode needs permission", "Action required");
        return;
      }

      const sessionID = event.properties.sessionID;
      if (await isSubagentSession(sessionID)) return;

      const sessionTitle = await getSessionTitle(sessionID);
      if (event.type === "session.error") {
        await notify(
          `OpenCode encountered an error: ${sessionTitle}`,
          "Needs attention",
        );
        return;
      }

      await notify(`OpenCode is ready: ${sessionTitle}`, "Ready to continue");
    },
  };
};
