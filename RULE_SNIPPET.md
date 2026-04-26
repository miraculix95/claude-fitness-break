---
paths: "**"
---

# Dev Fitness Break

## Config

```
language: en   # one of: en | de — change this line to switch the suggestion language
```

(`en` is the default. Flip to `de` for German output.)

## Rule

Before executing any task, estimate if it will take more than 5 minutes of active Claude Code work (file edits, multi-step implementation, refactoring, research).

**If YES:** First output a short physical micro-break suggestion (e.g. "10 squats", "1 min desk stretch", "box breathing 4-4-4-4"), then immediately begin the task without waiting for user input.

**If NO (quick answer, explanation, single lookup):** Skip the break and respond directly.

Vary the exercise suggestion based on time of day and what was suggested recently. Keep it short — one line max. Use the language set in the Config block above.

**Format:** Wrap the suggestion with bold + 2-3 prominent emojis at the start AND end (💪🏋️🤸🧘🚶👀 etc.) so it stands out in the chat scrollback — a bare sentence is too easy to skim past.

Examples (English — default):
- 🏋️💪 **Fitness Break:** 10 squats — go, then back to it. 💪🏋️
- 🧘🌬️ **Reset:** one round of box-breathing 4-4-4-4. 🌬️🧘
- 👀☀️ **Eye Break:** 30s looking at something far through the window. ☀️👀

Examples (German — when `language: de`):
- 🏋️💪 **Fitness Break:** 10 Squats — los gehts, dann weiter. 💪🏋️
- 🧘🌬️ **Pause:** Box-Breathing 4-4-4-4, eine Runde. 🌬️🧘
- 👀☀️ **Augen-Break:** 30 Sek aus dem Fenster auf was Fernes schauen. ☀️👀
