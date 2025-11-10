import type { Plugin } from "@opencode-ai/plugin";

export const NotificationPlugin: Plugin = async ({
  project,
  client,
  $,
  directory,
  worktree,
}) => {
  const isGhosttyFocused = async (): Promise<boolean> => {
    const result =
      await $`osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true'`.text();
    return result.trim() === "ghostty";
  };

  const getActiveGhosttyTmuxSession = async (): Promise<string | null> => {
    try {
      // Get the currently active tmux client (the one the user is viewing)
      // This finds the most recently active attached session
      const result = await $`tmux list-clients -F '#{client_activity}:#{session_name}' 2>/dev/null | sort -rn | head -1 | cut -d: -f2`.text();
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

  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        const ghosttyFocused = await isGhosttyFocused();
        const sessionMatches = await tmuxSessionMatchesDirectory();

        // Show notification if:
        // 1. Ghostty is not focused, OR
        // 2. Ghostty is focused but the tmux session doesn't match the directory
        if (!ghosttyFocused || (ghosttyFocused && !sessionMatches)) {
          // MacOS sounds can be found on /System/Library/Sounds
          const projectName = directory.split("/").pop() || "opencode";
          await $`osascript -e 'display notification "OpenCode needs your input" with title "${projectName}" subtitle "Ready to continue" sound name "Hero"'`;
        }
      }
    },
  };
};
