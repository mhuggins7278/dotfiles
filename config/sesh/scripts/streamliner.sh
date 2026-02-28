#!/usr/bin/env bash
tmux split-window -h -l 30%
tmux send-keys "fnm use && npm run local" Enter
tmux split-window
tmux select-pane -t :.0
tmux send-keys "fnm use default" Enter
tmux send-keys "opencode" Enter
tmux select-pane -t :.2
tmux send-keys "glgroup localdev up -p ../gds.clusterconfig.dev" Enter
tmux select-pane -t :.0
