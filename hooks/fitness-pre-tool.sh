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
FOCUS="${FITNESS_BREAK_FOCUS:-mixed}"                   # mixed (default) | fitness | stretching | yoga
INTENSITY="${FITNESS_BREAK_INTENSITY:-medium}"          # low | medium (default) | high
DRILL_SERGEANT="${FITNESS_BREAK_DRILL_SERGEANT:-0}"     # 0 (default) | 1 enables hardcore mode
DRILL_SECONDS="${FITNESS_BREAK_DRILL_SECONDS:-60}"      # pause duration in drill-sergeant mode

mkdir -p "$STATE_DIR"

now=$(date +%s)
last=0
[[ -f "$STATE_FILE" ]] && last=$(cat "$STATE_FILE" 2>/dev/null || echo 0)

if (( now - last < MIN_INTERVAL_SECONDS )); then
  exit 0
fi

# ── Drill Sergeant Mode (opt-in) ──────────────────────────────────────────────
# Pauses Claude Code for $DRILL_SECONDS while the user does the exercise that's
# advertised in settings.json `statusMessage`. After the pause, Claude Code
# pops the standard permission dialog with a confession-style label —
# the user picks Yes (proceed) or No (block this Edit).
#
# REQUIRES: companion `statusMessage` in your settings.json hook entry.
# Without it the user sees a frozen-looking terminal during the sleep.
# Recommended setup is in the README ("Drill Sergeant Mode" section).

if [[ "$DRILL_SERGEANT" == "1" ]]; then
  sleep "$DRILL_SECONDS"
  echo "$now" > "$STATE_FILE"

  if [[ "$LANG_CHOICE" == "de" ]]; then
    reason="🏋️ AUSBILDER fragt: Hast du die ${DRILL_SECONDS}s wirklich für Übungen genutzt? Future-Du beobachtet."
  else
    reason="🏋️ DRILL SERGEANT asks: Did you actually use the ${DRILL_SECONDS}s for exercise? Future-you is watching."
  fi

  escaped_reason=$(printf '%s' "$reason" | sed 's/\\/\\\\/g; s/"/\\"/g')
  cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "ask",
    "permissionDecisionReason": "$escaped_reason"
  }
}
EOF
  exit 0
fi
# ── End Drill Sergeant Mode ───────────────────────────────────────────────────

# ── Normal mode: pick from the fixed 30-exercise pool ─────────────────────────
# Entries are "category|name|low|medium|high". Exercise NAMES stay English in
# both languages; only the trailing wrapper localizes. `focus` selects the
# category (mixed = all three), `intensity` selects which tier number to show.

fitness=(
  "fitness|jumping jacks|15|25|40"
  "fitness|push-ups|10|20|30"
  "fitness|bodyweight squats|10|20|30"
  "fitness|wall sit|20s|40s|60s"
  "fitness|plank hold|20s|40s|60s"
  "fitness|side plank (per side)|15s|30s|45s"
  "fitness|abdominal crunches|10|20|30"
  "fitness|lunges (per leg)|6|10|15"
  "fitness|high knees|20s|40s|60s"
  "fitness|mountain climbers|20s|30s|45s"
  "fitness|triceps dips (chair edge)|8|15|25"
  "fitness|calf raises|15|25|40"
)
stretching=(
  "stretching|arm circles (each direction)|15s|30s|45s"
  "stretching|standing forward fold|20s|30s|45s"
  "stretching|doorway chest stretch (per side)|20s|30s|45s"
  "stretching|standing quad stretch (per leg)|20s|30s|45s"
  "stretching|overhead side bend (per side)|15s|30s|45s"
  "stretching|neck rolls + shoulder rolls|15s|25s|40s"
  "stretching|standing spinal twist (per side)|20s|30s|45s"
  "stretching|single-leg balance (per leg)|20s|30s|45s"
)
yoga=(
  "yoga|downward dog|20s|40s|60s"
  "yoga|cobra pose|15s|30s|45s"
  "yoga|child's pose|30s|45s|60s"
  "yoga|cat-cow|5 rounds|8 rounds|12 rounds"
  "yoga|low lunge (per side)|20s|30s|45s"
  "yoga|warrior II (per side)|20s|30s|45s"
  "yoga|tree pose (per side)|20s|30s|45s"
  "yoga|seated forward bend|20s|40s|60s"
  "yoga|bridge pose|20s|30s|45s"
  "yoga|sun salutation|1 round|2 rounds|3 rounds"
)

case "$FOCUS" in
  fitness)    pool=("${fitness[@]}") ;;
  stretching) pool=("${stretching[@]}") ;;
  yoga)       pool=("${yoga[@]}") ;;
  *)          pool=("${fitness[@]}" "${stretching[@]}" "${yoga[@]}") ;;  # mixed (default)
esac

entry="${pool[RANDOM % ${#pool[@]}]}"
IFS='|' read -r cat name low med high <<< "$entry"

case "$INTENSITY" in
  low)  tier="$low" ;;
  high) tier="$high" ;;
  *)    tier="$med" ;;  # medium (default)
esac

case "$cat" in
  stretching) e1="🤸🧘"; e2="🧘🤸"; label="Stretch" ;;
  yoga)       e1="🧘‍♀️🌿"; e2="🌿🧘‍♀️"; label="Yoga" ;;
  *)          e1="🏋️💪"; e2="💪🏋️"; label="Fitness Break" ;;
esac

if [[ "$LANG_CHOICE" == "de" ]]; then
  suffix="— dann weiter."
else
  suffix="— then back to work."
fi

message="${e1} **${label}:** ${tier} ${name} ${suffix} ${e2}"

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
