---
paths: "**"
---

# Dev Fitness Break

## Config

```
language:  en      # en | de — wrapper words only; exercise NAMES always stay English
focus:     mixed   # mixed | fitness | stretching | yoga — which category to draw from
intensity: medium  # low | medium | high — picks the rep/hold tier (the a / b / c numbers in the pool)
```

- `language` — `en` default. Flips only the wrapper words ("los gehts"), never the exercise names.
- `focus` — `mixed` (default) rotates across all three categories. Set to one category to stay in it.
- `intensity` — `medium` default. Each pool entry lists three tiers `low / medium / high`; use the one matching this knob (e.g. push-ups `10 / 20 / 30` → `medium` = 20).

## Rule

Before executing any task, estimate if it will take more than 5 minutes of active Claude Code work (file edits, multi-step implementation, refactoring, research).

**If YES:** First output a short physical micro-break suggestion, then immediately begin the task without waiting for user input.

**If NO (quick answer, explanation, single lookup):** Skip the break and respond directly.

Pick **one** exercise from the pool at the bottom — never improvise your own. Honor the Config: draw from the category set by `focus` (or rotate across all three when `mixed`), and use the rep/hold number from the tier set by `intensity`. Rotate so you don't repeat recent suggestions. Keep it to one line. **Exercise names always stay in English**, even when `language: de` — only the wrapper words ("los gehts", "dann weiter") localize.

**Format:** Wrap the suggestion with bold + 2-3 prominent emojis at the start AND end (💪🏋️🤸🧘🚶👀 etc.) so it stands out in the chat scrollback — a bare sentence is too easy to skim past.

Examples (English — default):
- 🏋️💪 **Fitness Break:** 20 push-ups — go, then back to it. 💪🏋️
- 🤸🧘 **Stretch:** 30s standing forward fold. 🧘🤸
- 🧘‍♀️🌿 **Yoga:** 40s downward dog. 🌿🧘‍♀️

Examples (German — when `language: de`; exercise names stay English):
- 🏋️💪 **Fitness Break:** 20 push-ups — los gehts, dann weiter. 💪🏋️
- 🤸🧘 **Stretch:** 30s standing forward fold. 🧘🤸
- 🧘‍♀️🌿 **Yoga:** 40s downward dog — los gehts. 🌿🧘‍♀️

## Exercise Pool (30 — fixed; pick by `focus`, scale by `intensity`)

Standard, recognizable, no-equipment moves (chair/wall/floor optional). Each line shows three intensity tiers: **low / medium / high**. The Fitness block is the canonical Scientific 7-Minute Workout (ACSM Health & Fitness Journal, 2013) plus standard calisthenics. Pick one, rotate, names stay English.

### Fitness (active / 7MWC-style) → `focus: fitness`
1. Jumping jacks — 15 / 25 / 40
2. Push-ups — 10 / 20 / 30
3. Bodyweight squats — 10 / 20 / 30
4. Wall sit — 20s / 40s / 60s
5. Plank hold — 20s / 40s / 60s
6. Side plank (per side) — 15s / 30s / 45s
7. Abdominal crunches — 10 / 20 / 30
8. Lunges (per leg) — 6 / 10 / 15
9. High knees — 20s / 40s / 60s
10. Mountain climbers — 20s / 30s / 45s
11. Triceps dips (chair edge) — 8 / 15 / 25
12. Calf raises — 15 / 25 / 40

### Stretching / mobility → `focus: stretching`
13. Arm circles (each direction) — 15s / 30s / 45s
14. Standing forward fold (hamstring) — 20s / 30s / 45s
15. Doorway chest stretch (per side) — 20s / 30s / 45s
16. Standing quad stretch (per leg) — 20s / 30s / 45s
17. Overhead side bend (per side) — 15s / 30s / 45s
18. Neck rolls + shoulder rolls — 15s / 25s / 40s
19. Standing spinal twist (per side) — 20s / 30s / 45s
20. Single-leg balance (per leg) — 20s / 30s / 45s

### Yoga → `focus: yoga`
21. Downward dog — 20s / 40s / 60s
22. Cobra pose — 15s / 30s / 45s
23. Child's pose — 30s / 45s / 60s
24. Cat-cow — 5 / 8 / 12 rounds
25. Low lunge (per side) — 20s / 30s / 45s
26. Warrior II (per side) — 20s / 30s / 45s
27. Tree pose (per side) — 20s / 30s / 45s
28. Seated forward bend — 20s / 40s / 60s
29. Bridge pose — 20s / 30s / 45s
30. Sun salutation — 1 / 2 / 3 rounds
