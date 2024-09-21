#!/usr/bin/env bash
tmux split-window -h -l 30%
tmux send-keys "fnm use" Enter
tmux select-pane -t :.0
tmux send-keys "nvim ." Enter
