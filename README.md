# claude-fitness-break

> Your AI pair programmer is tireless. You are not.

A tiny drop-in for [Claude Code](https://claude.com/claude-code) that makes Claude suggest a 30-second physical micro-break before long tasks — **then gets on with the work without waiting for you to agree.**

No prompts. No interruptions. No "would you like to take a break?" dialog from hell. Just: squat, stretch, breathe, build.

## What it looks like

You ask Claude for something non-trivial. It opens with one line, then immediately starts the work:

```
You: refactor the auth middleware to use the new session service

Claude: 🏋️💪 **Fitness Break:** 20 push-ups — then back to work. 💪🏋️

        Reading app/middleware/auth.ts...
        [normal Claude Code output continues]
```

Or for the deterministic hook (Option C below), the suggestion is injected before any `Write`/`Edit` tool call — **rate-limited to once every 30 minutes by default, configurable** to e.g. 10 min via `FITNESS_BREAK_INTERVAL=600`:

```
🏋️💪 **Fitness Break:** 25 jumping jacks — then back to work. 💪🏋️
```

German output (when `language: de` / `FITNESS_BREAK_LANG=de` — exercise names stay English):

```
🤸🧘 **Stretch:** 30s doorway chest stretch (per side) — dann weiter. 🧘🤸
```

That's it. No buttons, no ack required, no waiting.

## Why

Claude Code will happily refactor your monorepo while you slowly fuse with the chair. This repo is the smallest possible counterweight: one rule file, one exercise library, one optional hook.

It won't fix your posture. It will remind you that you have legs.

## Which option should I pick?

Three install paths below. Pick by your Claude Code setup, not by gut feel:

| Your situation | Pick | Why |
|---|---|---|
| Fresh / minimal Claude Code setup, short or no `CLAUDE.md` | **B** (CLAUDE.md snippet) | Lowest-friction install. `CLAUDE.md` is loaded every turn, the rule fires reliably. |
| You already use `~/.claude/rules/`, modest size | **A** (rule file) | Clean install, no `CLAUDE.md` bloat, Claude estimates task size and skips trivial work. `rm` to disable. |
| Heavy `CLAUDE.md` (multiple kB) + many rules competing for attention | **C** (hook) | Model-attention is finite; with a busy instruction set, soft rules can be drowned out. The hook fires deterministically on every Write/Edit and doesn't depend on the model "remembering" the rule. Configurable interval (default 30 min). |
| You want a guaranteed cadence regardless of what Claude is doing | **C** (hook) | Mechanical timer, configurable interval (default 30 min, can go shorter or longer), ignores task-size judgement. |
| Any of A/B feels too soft in practice | Combine **A** + **C** | Rule for task-aware suggestions, hook as a hard floor. They don't conflict. |
| You want hardcore: a real 60s pause + accountability prompt | **C** with **Drill Sergeant Mode** | Hook actually blocks Claude Code while you do the exercise. See section below. |

**Heuristic:** if Claude already follows your rules predictably, A or B works. If you've ever caught yourself thinking *"why didn't Claude do the thing I told it to in CLAUDE.md?"* — your instruction set has grown past the point where soft rules are reliable. Use C.

## Install — Option A: Rule file

Drop a single file into `~/.claude/rules/` — Claude Code auto-loads it. Doesn't bloat your `CLAUDE.md`, easy to disable (delete the file), and the rule is applied **only when Claude estimates the task is non-trivial** (>5 minutes of active work). Quick lookups stay quick.

```bash
mkdir -p ~/.claude/rules
curl -fsSL https://raw.githubusercontent.com/miraculix95/claude-fitness-break/main/RULE_SNIPPET.md \
  -o ~/.claude/rules/fitness-break.md
```

Done. Start a new Claude Code session and ask for something non-trivial. You'll get a one-line exercise prompt, then Claude starts working.

Disable: `rm ~/.claude/rules/fitness-break.md`.

## Install — Option B: Append to CLAUDE.md

Simpler if you don't use the `~/.claude/rules/` pattern. Append `CLAUDE_MD_SNIPPET.md` to `~/.claude/CLAUDE.md`:

```bash
curl -fsSL https://raw.githubusercontent.com/miraculix95/claude-fitness-break/main/CLAUDE_MD_SNIPPET.md \
  >> ~/.claude/CLAUDE.md
```

Same behavior as Option A — Claude estimates task size and decides whether to suggest a break. Slightly more invasive: lives in your global `CLAUDE.md` instead of a dedicated file.

## Install — Option C: PreToolUse hook (deterministic)

The rule and snippet rely on Claude's own judgement. The hook is mechanical: it fires on `Write` / `Edit` / `MultiEdit` tool calls, rate-limited to once per 30 min by default.

**Trade-off:** the hook fires regardless of task size — even a typo fix counts. The rule lets Claude skip breaks for trivial work; the hook is "every Write within 30 minutes triggers a suggestion." Pick based on whether you want flexibility (rule) or guarantees (hook).

```bash
mkdir -p ~/.claude/hooks
curl -fsSL https://raw.githubusercontent.com/miraculix95/claude-fitness-break/main/hooks/fitness-pre-tool.sh \
  -o ~/.claude/hooks/fitness-pre-tool.sh
chmod +x ~/.claude/hooks/fitness-pre-tool.sh
```

Then wire it into `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Write|Edit|MultiEdit",
      "hooks": [{
        "type": "command",
        "command": "~/.claude/hooks/fitness-pre-tool.sh"
      }]
    }]
  }
}
```

### Hook frequency

By default the hook fires at most **once every 30 minutes** (1800 seconds). Override via `FITNESS_BREAK_INTERVAL` — set inline in the `settings.json` command, **not** as a shell env-var (the hook subprocess doesn't inherit your shell environment):

```json
"command": "FITNESS_BREAK_INTERVAL=600 ~/.claude/hooks/fitness-pre-tool.sh"
```

| Value | Meaning |
|---|---|
| `300` | every 5 min (aggressive — for marathon edit sessions) |
| `600` | every 10 min |
| `1800` | every 30 min (default — comfortable for most workflows) |
| `3600` | every hour (gentle reminder) |
| `7200` | every 2 hours (almost off — useful as a sanity floor) |

Pick what you'd actually do — 5-min squats are great in theory, ignored in practice. 30 min is the default for a reason.

The hook emits a JSON `hookSpecificOutput.additionalContext` payload to stdout, which Claude Code injects into the model's context — that's how the message becomes visible. Plain `echo` to stdout/stderr would be silently swallowed (this is a Claude Code hook protocol requirement, not a script bug).

The hook can be combined with Option A or B — rule-based suggestions for thinking-heavy tasks, hook-based for guaranteed coverage on edit-heavy sessions.

### Hook focus & intensity

The hook draws from the same 30-move pool as the rule ([`exercises.md`](./exercises.md)), with the same two knobs. Set them inline in the `settings.json` command — shell env-vars don't reach the hook subprocess (same caveat as the interval):

| Env var | Default | Values |
|---|---|---|
| `FITNESS_BREAK_FOCUS` | `mixed` | `mixed` · `fitness` · `stretching` · `yoga` |
| `FITNESS_BREAK_INTENSITY` | `medium` | `low` · `medium` · `high` |

```json
"command": "FITNESS_BREAK_FOCUS=yoga FITNESS_BREAK_INTENSITY=low ~/.claude/hooks/fitness-pre-tool.sh"
```

Unknown values fall back to the defaults. Exercise names stay English; only the wrapper localizes via `FITNESS_BREAK_LANG`. (Drill Sergeant Mode below is the exception — it uses your own `statusMessage`, not the pool.)

## Drill Sergeant Mode (opt-in, hook-only)

> "I will not move on until you confirm you did the push-ups."

A maximalist variant of Option C. Instead of injecting a one-line suggestion that Claude breezes past, the hook **actually pauses Claude Code for 60 seconds** while you do the exercise — then pops a permission dialog asking you to confess whether you did it. No way to skip without lying to your future self.

This is **not the default**. You have to explicitly turn it on.

### What you see

```
[You ask Claude to edit some file]

🏋️ DRILL SERGEANT — pick: 15 PUSH-UPS / 20 SQUATS / 30s PLANK / 25 BURPEES. NOW.
   ╱ ╲ (spinner runs for 60 seconds while you do them)

[After 60s, the standard Claude Code permission dialog pops up]

  Allow Edit on auth.py?
  [🏋️ DRILL SERGEANT asks: Did you actually use the 60s for exercise? Future-you is watching.]
  1. Yes
  2. Yes, and don't ask again
  3. No, tell Claude what to do differently
```

You pick whatever. Claude Code doesn't actually verify you did anything. The point is the friction: every Yes is a tiny moment of accountability with yourself.

### Setup

Drill Sergeant Mode requires both an env var **and** a `statusMessage` in your `settings.json` hook entry — otherwise the user sits in a frozen-looking terminal during the 60s pause (Claude Code's hook stderr is buffered, so the script can't print live progress; `statusMessage` is the only documented way to surface a live indicator).

```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Write|Edit|MultiEdit",
      "hooks": [{
        "type": "command",
        "command": "FITNESS_BREAK_DRILL_SERGEANT=1 FITNESS_BREAK_LANG=de FITNESS_BREAK_INTERVAL=1800 ~/.claude/hooks/fitness-pre-tool.sh",
        "statusMessage": "🏋️ AUSBILDER — wähle: 15 LIEGESTÜTZE / 20 KNIEBEUGEN / 30s PLANK / 25 BURPEES. JETZT."
      }]
    }]
  }
}
```

The `statusMessage` is **the visible part during the pause** — Claude Code limits you to one static line, so menu format gives you variety without needing dynamic generation. List 3-5 concrete exercises you're actually willing to do; you pick which one each time the prompt fires. Generic phrases like "do something" defeat the purpose — every option has to be specific enough that you can't lie to yourself about whether you did it.

### Tunables

| Env var | Default | Effect |
|---|---|---|
| `FITNESS_BREAK_DRILL_SERGEANT` | `0` (off) | Set to `1` to enable |
| `FITNESS_BREAK_DRILL_SECONDS` | `60` | Pause length in seconds. Match this in your `statusMessage`. |
| `FITNESS_BREAK_INTERVAL` | `1800` | Min seconds between firings — same as normal mode. Don't go below 1200 in drill-sergeant mode unless you actually want a 60s pause every 5 min. |
| `FITNESS_BREAK_LANG` | `en` | `de` switches the confession prompt to German. The `statusMessage` is yours to write. |

### English statusMessage example

```json
"statusMessage": "🏋️ DRILL SERGEANT — pick: 15 PUSH-UPS / 20 SQUATS / 30s PLANK / 25 BURPEES. NOW."
```

### Why this is provocative on purpose

The honor system **does not** verify you did the exercise. That's intentional. The mechanism is:

1. The pause is **real** — Claude Code is genuinely blocked for 60s, you can't speed past it.
2. The exercise prescription is **specific** in your own `statusMessage`, so saying "I did 10 squats" requires either doing 10 squats or being a person who lies to permission dialogs alone in their office.
3. The confession-style permission label puts the cognitive cost of cheating on you, every time.

Will you cheat sometimes? Yes. Will the friction still increase the number of squats per week vs. baseline? Also yes. That's the whole game.

If you find yourself reflexively dismissing the prompt every time, turn it off — the soft-rule mode (Option A/B) is for you. Drill Sergeant is for people who explicitly want hardcore.

## Language

Default output is **English**. Both the rule snippets (Options A & B) and the hook (Option C) support German as well.

**Option A / B (rule + CLAUDE.md):** edit one line near the top of the file you installed.

```diff
- language:  en      # en | de — wrapper words only; exercise NAMES always stay English
+ language:  de
```

Then start a new Claude Code session — the next break will be in German.

**Option C (hook):** set `FITNESS_BREAK_LANG=de` inline in the `settings.json` command, alongside the interval override:

```json
"command": "FITNESS_BREAK_LANG=de FITNESS_BREAK_INTERVAL=1800 ~/.claude/hooks/fitness-pre-tool.sh"
```

(Same caveat as the interval: env-vars set in your shell don't reach the hook subprocess — must be inline.)

Want another language? Open a PR with translated example lines in `RULE_SNIPPET.md` / `CLAUDE_MD_SNIPPET.md` and a parallel pool in `hooks/fitness-pre-tool.sh`. The structure is straightforward to copy.

## The exercise library

See [`exercises.md`](./exercises.md) — **30 moves** across three categories (**fitness** / **stretching** / **yoga**), each with **low / medium / high** intensity tiers. All desk-friendly, no equipment, nothing that makes you sweat into your keyboard. The fitness block is the canonical [Scientific 7-Minute Workout](https://www.webmd.com/fitness-exercise/ss/the-7-minute-workout-slideshow) plus standard calisthenics.

Two knobs in the Config block control what you get:

- **`focus`** — `mixed` (default), `fitness`, `stretching`, or `yoga`.
- **`intensity`** — `low` / `medium` / `high`, scaling each move (e.g. push-ups `10 / 20 / 30`).

Claude picks one, rotates so it doesn't repeat, and uses the tier matching your `intensity`. Exercise names stay English even on `language: de`. The `focus` / `intensity` switches work in all three install options — the hook reads them as env vars (see [Hook focus & intensity](#hook-focus--intensity)).

## FAQ

**Will this slow Claude down?** No. Claude emits one line of text, then starts the task in the same turn. You read it or you don't.

**Does it actually work?** Try it for a week. The bar for "better than nothing" is very low.

**Why is the rule file better than appending to CLAUDE.md?** `~/.claude/CLAUDE.md` loads into every session and costs tokens every turn. A `~/.claude/rules/*.md` file with a `paths` filter is the cleaner pattern Claude Code already supports — and `rm` disables it.

**Why is the hook the "less smart" option?** Hooks fire deterministically on tool-call events. They don't know if your edit is a 1-character typo fix or a 200-line refactor. The rule lets Claude estimate task size and skip when it's trivial. Use the hook only if you want guaranteed firing regardless of context.

**Can I replace the exercises with push-up counts scaled to my 1RM?** Yes, edit `exercises.md`. It's a markdown file.

**What about "standing desk = free workout" people?** This is for you too. Standing statically for 6 hours is not movement.

## Contributing

PRs welcome, especially:
- more exercises (keep them desk-friendly and short)
- hook variants for other editors / agents
- additional languages (English + German ship today; the structure is the same in `RULE_SNIPPET.md`, `CLAUDE_MD_SNIPPET.md`, and `hooks/fitness-pre-tool.sh`)

## License

MIT — see [`LICENSE`](./LICENSE). Go lift something.

---

Built by [Bastian](https://www.linkedin.com/in/bastian-buechner/) — freelance AI/Python dev in Munich. Available on [Malt](https://www.malt.com/).
