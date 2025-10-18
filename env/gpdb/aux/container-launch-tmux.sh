#!/bin/bash

# This file will be placed inside of the container.

SESSION_NAME="gpdb"

tmux kill-session -t "$SESSION_NAME" 2>/dev/null

tmux new-session -d -s "$SESSION_NAME"

tmux new-window -t "$SESSION_NAME"
tmux send-keys -t "$SESSION_NAME:2" 'su gpadmin' Enter
tmux send-keys -t "$SESSION_NAME:2" 'cd gpdb_src' Enter

tmux new-window -t "$SESSION_NAME"
tmux send-keys -t "$SESSION_NAME:3" 'su gpadmin' Enter
tmux send-keys -t "$SESSION_NAME:3" '~/setup-resgroups' Enter
tmux send-keys -t "$SESSION_NAME:3" '. ~/env' Enter

tmux select-window -t "$SESSION_NAME:1"

tmux attach-session -t "$SESSION_NAME"
