#!/usr/bin/env bash
# claude-fitness-break — PreToolUse hook (v2 skeleton)
#
# Fires before Claude Code uses Write/Edit/MultiEdit tools. Emits a micro-break
# suggestion to stderr, which Claude Code surfaces to the user as additional
# context. Rate-limited so you don't get a break every 3 seconds.
#
# Wire up in ~/.claude/settings.json:
#   {
#     "hooks": {
#       "PreToolUse": [{
#         "matcher": "Write|Edit|MultiEdit",
#         "hooks": [{
#           "type": "command",
#           "command": "~/.claude/hooks/fitness-pre-tool.sh"
#         }]
#       }]
#     }
#   }
#
# Exit 0 = allow the tool call. Exit 2 = block (we never block).

set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/claude-fitness-break"
STATE_FILE="$STATE_DIR/last-break"
MIN_INTERVAL_SECONDS="${FITNESS_BREAK_INTERVAL:-1800}"  # 30 min default

mkdir -p "$STATE_DIR"

now=$(date +%s)
last=0
[[ -f "$STATE_FILE" ]] && last=$(cat "$STATE_FILE" 2>/dev/null || echo 0)

if (( now - last < MIN_INTERVAL_SECONDS )); then
  exit 0
fi

hour=$(date +%H)
if (( hour < 11 )); then
  bucket="morning"
  pool=("10 bodyweight squats" "20 jumping jacks" "1 min standing forward fold" "10 arm circles each direction")
elif (( hour < 17 )); then
  bucket="midday"
  pool=("15 desk push-ups" "30s doorway chest stretch per side" "box breathing 4-4-4-4 for 1 min" "10-10-10: squats/push-ups/lunges" "stand up and look 20m away for 30s")
else
  bucket="evening"
  pool=("4-7-8 breathing, 4 rounds" "30s pigeon pose per side" "1 min child's pose with slow breath" "legs-up-the-wall for 1 min")
fi

pick="${pool[RANDOM % ${#pool[@]}]}"

echo "🏋️ Fitness break (${bucket}): ${pick} — then back to work." >&2

echo "$now" > "$STATE_FILE"
exit 0
