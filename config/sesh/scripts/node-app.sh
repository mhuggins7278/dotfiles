#!/usr/bin/env bash
tmux split-window -h -l 30%
tmux send-keys "fnm use" Enter
tmux select-pane -t :.0
# Run fnm use default in a way that persists after nvim exits
tmux send-keys "fnm use default" Enter
tmux send-keys "clear" Enter
tmux send-keys "nvim ." Enter
