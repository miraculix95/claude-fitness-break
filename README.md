# claude-fitness-break

> Your AI pair programmer is tireless. You are not.

A tiny drop-in for [Claude Code](https://claude.com/claude-code) that makes Claude suggest a 30-second physical micro-break before long tasks — **then gets on with the work without waiting for you to agree.**

No prompts. No interruptions. No "would you like to take a break?" dialog from hell. Just: squat, stretch, breathe, build.

## What it looks like

You ask Claude for something non-trivial. It opens with one line, then immediately starts the work:

```
You: refactor the auth middleware to use the new session service

Claude: 🏋️💪 **Fitness Break** (midday): 10 desk push-ups — then back to work. 💪🏋️

        Reading app/middleware/auth.ts...
        [normal Claude Code output continues]
```

Or for the deterministic hook (Option C below), the suggestion is injected before any `Write`/`Edit` tool call:

```
🏋️💪 **Fitness Break** (morning): 10 bodyweight squats — then back to work. 💪🏋️
```

German output (when `language: de` / `FITNESS_BREAK_LANG=de`):

```
🏋️💪 **Fitness Break** (mittags): 30 Sek Brust-Dehnung im Tuerrahmen pro Seite — dann weiter. 💪🏋️
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
| Heavy `CLAUDE.md` (multiple kB) + many rules competing for attention | **C** (hook) | Model-attention is finite; with a busy instruction set, soft rules can be drowned out. The hook fires deterministically on every Write/Edit and doesn't depend on the model "remembering" the rule. |
| You want a guaranteed cadence regardless of what Claude is doing | **C** (hook) | Mechanical timer, ignores task-size judgement. |
| Any of A/B feels too soft in practice | Combine **A** + **C** | Rule for task-aware suggestions, hook as a hard floor. They don't conflict. |

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

**Override the interval** by prefixing the command in `settings.json`:

```json
"command": "FITNESS_BREAK_INTERVAL=600 ~/.claude/hooks/fitness-pre-tool.sh"
```

(Setting `FITNESS_BREAK_INTERVAL=600` here = 10 minutes between breaks. Default is 1800 = 30 minutes. Note: setting it via shell env-var doesn't reach the hook subprocess — must be inline in the command.)

The hook emits a JSON `hookSpecificOutput.additionalContext` payload to stdout, which Claude Code injects into the model's context — that's how the message becomes visible. Plain `echo` to stdout/stderr would be silently swallowed (this is a Claude Code hook protocol requirement, not a script bug).

The hook can be combined with Option A or B — rule-based suggestions for thinking-heavy tasks, hook-based for guaranteed coverage on edit-heavy sessions.

## Language

Default output is **English**. Both the rule snippets (Options A & B) and the hook (Option C) support German as well.

**Option A / B (rule + CLAUDE.md):** edit one line near the top of the file you installed.

```diff
- language: en   # one of: en | de — change this line to switch the suggestion language
+ language: de
```

Then start a new Claude Code session — the next break will be in German.

**Option C (hook):** set `FITNESS_BREAK_LANG=de` inline in the `settings.json` command, alongside the interval override:

```json
"command": "FITNESS_BREAK_LANG=de FITNESS_BREAK_INTERVAL=1800 ~/.claude/hooks/fitness-pre-tool.sh"
```

(Same caveat as the interval: env-vars set in your shell don't reach the hook subprocess — must be inline.)

Want another language? Open a PR with translated example lines in `RULE_SNIPPET.md` / `CLAUDE_MD_SNIPPET.md` and a parallel pool in `hooks/fitness-pre-tool.sh`. The structure is straightforward to copy.

## The exercise library

See [`exercises.md`](./exercises.md) — about 20 moves, bucketed by time of day (morning / midday / evening) and duration (30s / 1min / 2min). All desk-friendly, no equipment, nothing that makes you sweat into your keyboard.

Claude varies the pick. The hook randomizes from a time-of-day pool.

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
