#!/usr/bin/env bash
tmux split-window -h -l 30%
tmux select-pane -t :.0
tmux send-keys "vp env use lts" Enter
tmux send-keys "clear" Enter
tmux send-keys "opencode" Enter
