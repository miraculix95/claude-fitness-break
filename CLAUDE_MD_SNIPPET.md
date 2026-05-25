## 🏋️ Dev Fitness Break

**Config:**
- `language: en` — `en` | `de`. Wrapper words only; exercise NAMES always stay English.
- `focus: mixed` — `mixed` | `fitness` | `stretching` | `yoga`. Which category to draw from.
- `intensity: medium` — `low` | `medium` | `high`. Picks the rep/hold tier (the `a / b / c` numbers below).

Before executing any task, estimate if it will take more than 5 minutes of active Claude Code work (file edits, multi-step implementation, refactoring, research).

**If YES:** First output a short physical micro-break suggestion, then immediately begin the task without waiting for user input.

**If NO (quick answer, explanation, single lookup):** Skip the break and respond directly.

Pick **one** exercise from the pool below — never improvise your own. Draw from the category set by `focus` (rotate across all three when `mixed`), and use the number from the tier set by `intensity`. Rotate so you don't repeat recent suggestions. Keep it to one line.

**Format:** bold + 2-3 prominent emojis at start AND end (💪🏋️🤸🧘🚶👀) — e.g. `🏋️💪 **Fitness Break:** 20 push-ups — go, then back to it. 💪🏋️`.

**Pool (30 — pick by `focus`, scale by `intensity`; tiers are low / medium / high):**

`fitness`: jumping jacks 15/25/40 · push-ups 10/20/30 · bodyweight squats 10/20/30 · wall sit 20s/40s/60s · plank hold 20s/40s/60s · side plank per side 15s/30s/45s · abdominal crunches 10/20/30 · lunges per leg 6/10/15 · high knees 20s/40s/60s · mountain climbers 20s/30s/45s · triceps dips (chair) 8/15/25 · calf raises 15/25/40

`stretching`: arm circles each dir 15s/30s/45s · standing forward fold 20s/30s/45s · doorway chest stretch per side 20s/30s/45s · standing quad stretch per leg 20s/30s/45s · overhead side bend per side 15s/30s/45s · neck + shoulder rolls 15s/25s/40s · standing spinal twist per side 20s/30s/45s · single-leg balance per leg 20s/30s/45s

`yoga`: downward dog 20s/40s/60s · cobra pose 15s/30s/45s · child's pose 30s/45s/60s · cat-cow 5/8/12 rounds · low lunge per side 20s/30s/45s · warrior II per side 20s/30s/45s · tree pose per side 20s/30s/45s · seated forward bend 20s/40s/60s · bridge pose 20s/30s/45s · sun salutation 1/2/3 rounds
