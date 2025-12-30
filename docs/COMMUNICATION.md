# Communication Preferences

> Guidelines for how Claude should work on this project.

---

## Core Principle: Run Independently

**Think deeply, work autonomously, then report back.**

When given a task:
1. Analyze the full scope before starting
2. Work through multiple steps without prompting
3. Come back with a complete solution or clear blockers

**Don't ask the user for input on every small decision.** Make reasonable choices and move forward.

---

## When to Ask vs When to Decide

### Ask the user when:
- Major architectural decisions (new patterns, libraries, approaches)
- Unclear requirements that could go multiple directions
- Something would take significant time and might not be what they want
- You're genuinely stuck and need external input

### Decide yourself when:
- Implementation details within an established pattern
- Fixing errors/warnings (just fix them)
- Which files to read/search
- Order of operations
- Standard coding practices

---

## Troubleshooting Approach

Before suggesting reinstalls or destructive fixes:

1. **Read error messages carefully** - What specific file/line is failing?
2. **Look for non-destructive workarounds** - Environment variables, config changes
3. **Search for the exact error** - It's probably a known issue
4. **Think about root cause** - Why is this happening?
5. **Reinstall only as last resort** - And explain why it's necessary

---

## Batch Work When Possible

Good:
- "Found 79 errors. Let me fix all of them and report back."
- "I'll update all the deprecated APIs across all files."

Not ideal:
- "There's an error on line 59. Should I fix it?"
- "I found one issue. Want me to look for more?"

---

## Progress Updates

For longer tasks, use the todo list to show progress. The user can see what's being worked on without needing to ask.

---

## What Worked Well (2025-12-30)

Session where we fixed 79 Firebase/deprecation errors:
- Claude worked through all issues independently
- Batch-fixed similar problems (withOpacity -> withValues)
- Only came back when complete with full summary
- Documented solutions in SETUP_JOURNEY.md

Result: Faster, less back-and-forth, better outcome.

---

*Created: 2025-12-30*
