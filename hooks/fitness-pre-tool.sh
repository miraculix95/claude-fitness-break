#!/usr/bin/env bash
# claude-fitness-break — PreToolUse hook (v3, JSON output)
#
# Fires before Claude Code uses Write/Edit/MultiEdit tools. Emits a JSON
# object with hookSpecificOutput.additionalContext — Claude Code injects
# that into the model's context, which surfaces the message in the
# conversation. Rate-limited so you don't get a break every 3 seconds.
#
# Earlier versions echo'd plain text (stderr or stdout) — Claude Code
# silently swallows that. Modern hook protocol requires the JSON shape
# below for the message to be visible.
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
LANG_CHOICE="${FITNESS_BREAK_LANG:-en}"                 # en (default) | de

mkdir -p "$STATE_DIR"

now=$(date +%s)
last=0
[[ -f "$STATE_FILE" ]] && last=$(cat "$STATE_FILE" 2>/dev/null || echo 0)

if (( now - last < MIN_INTERVAL_SECONDS )); then
  exit 0
fi

hour=$(date +%-H)  # %-H strips leading zero — "09" would be invalid octal in (( )) arithmetic

if [[ "$LANG_CHOICE" == "de" ]]; then
  if (( hour < 11 )); then
    bucket="morgens"
    pool=("10 Kniebeugen" "20 Hampelmaenner" "1 Min Vorbeuge im Stehen" "10 Armkreise pro Richtung")
  elif (( hour < 17 )); then
    bucket="mittags"
    pool=("15 Schreibtisch-Liegestuetze" "30 Sek Brust-Dehnung im Tuerrahmen pro Seite" "1 Min Box-Breathing 4-4-4-4" "10-10-10: Squats/Pushups/Lunges" "aufstehen und 30 Sek auf was 20m Entferntes schauen")
  else
    bucket="abends"
    pool=("4-7-8 Atmung, 4 Runden" "30 Sek Taube pro Seite" "1 Min Kindhaltung mit langsamer Atmung" "1 Min Beine-an-die-Wand")
  fi
  prefix="**Fitness Break** (${bucket})"
  suffix="— dann weiter."
else
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
  prefix="**Fitness Break** (${bucket})"
  suffix="— then back to work."
fi

pick="${pool[RANDOM % ${#pool[@]}]}"
message="🏋️💪 ${prefix}: ${pick} ${suffix} 💪🏋️"

# JSON to stdout — Claude Code injects additionalContext into model.
# Escape any double-quotes / backslashes in message (defensive, pool entries
# are static and safe but cheap to harden).
escaped_message=$(printf '%s' "$message" | sed 's/\\/\\\\/g; s/"/\\"/g')
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "additionalContext": "$escaped_message"
  }
}
EOF

echo "$now" > "$STATE_FILE"
exit 0
