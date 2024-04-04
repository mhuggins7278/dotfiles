#!/usr/bin/env bash
tmux split-window -h -l 30%
tmux send-keys "nvmit" Enter
tmux select-pane -t :.+
tmux send-keys "nvim ." Enter
