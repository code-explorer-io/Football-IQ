# AI Autonomous App Progression Playbook

A practical, reusable framework for letting AI (Claude / ChatGPT) move your app forward **without micromanagement**.

---

## Why This Exists

Most solo builders get stuck after v1:
> *"It works... but I don't know what to do next."*

This playbook turns AI into:
- A **junior PM**
- A **senior engineer**
- A **ruthlessly honest reviewer**

The goal is **momentum**, not perfection.

---

## Core Principle

> **Autonomy only works when AI is given agency, pressure, and constraints.**

Every prompt in this playbook:
- Forces decisions
- Produces real output
- Moves the product closer to launch, usage, or revenue

---

## The Core Autonomy Loop (Use This Every Time)

Paste this once as a **system prompt**:

```
You are a senior product engineer and product manager.
Your job is to independently move this app forward.

You must:
- Identify the highest-leverage next improvement
- Make a concrete plan
- Produce real output (code, copy, spec, checklist)
- Explain tradeoffs briefly
- Propose the next iteration

Avoid vague suggestions.
Prefer shipping over perfection.
```

Then run this loop repeatedly:

```
Given the current state of my app:
1. Identify the single most valuable improvement I should make next.
2. Explain why this matters now (not later).
3. Produce the actual deliverable (code, UI copy, PRD, tests, etc).
4. List what you would do next if you had another hour.
```

---

## Top 15 High-Leverage Autonomous Prompts

Use these when you're unsure where to go next but want **real progress**.

---

### 1. Brutally Honest Review

```
Act as a brutally honest senior engineer reviewing this app.
Assume users are impatient and unforgiving.

List:
- The top 5 things that will frustrate users
- The top 3 reasons they might uninstall
- The single most dangerous flaw

Then fix the worst issue directly.
```

Best when things feel "fine but not exciting".

---

### 2. Launch Readiness Audit

```
Assume I want to ship this app publicly in 7 days.

Create:
- A launch readiness checklist (grouped by priority)
- Missing features vs nice-to-haves
- Bugs or edge cases likely in real usage

Then pick one blocker and resolve it fully.
```

Forces real-world thinking.

---

### 3. User Journey Mapping

```
Map the full user journey from:
Install > First Open > First Success > Habit Formation.

Identify:
- Drop-off points
- Confusion moments
- Missing feedback or delight

Rewrite the UX copy or flow to fix the worst drop-off.
```

Excellent for retention.

---

### 4. Make It 10x Simpler

```
Assume users have zero patience.

Simplify:
- Onboarding
- Core flow
- Any decision the user must make

Remove steps, reduce text, and rewrite UI copy.
Provide the exact revised flow.
```

Simplicity beats features.

---

### 5. Edge Case Hunter

```
Enumerate all realistic edge cases:
- Empty states
- Slow networks
- Partial inputs
- Returning users after weeks away
- Power users who exhaust content

Prioritise the top 3 that could break trust.
Implement guards or UI feedback for them.
```

This is where apps start to feel polished.

---

### 6. Monetisation Without Ruining UX

```
Propose 3 monetisation strategies that:
- Feel fair to users
- Don't interrupt core gameplay/flow
- Can be implemented quickly

For the best option:
- Define pricing
- Define trigger moment (when to show)
- Write the paywall or upsell copy
```

Even if you don't ship it yet, this clarifies direction.

---

### 7. Product Manager for a Day

```
Act as the product manager for this app.

Define:
- North star metric (the one number that matters)
- 3 supporting metrics
- What success looks like in 30 days

Then suggest 1 feature or change that improves the north star metric.
```

Stops random feature building.

---

### 8. Kill Your Darlings

```
Assume this app must be cut down by 30%.

Identify:
- Features that add complexity without value
- Anything users won't notice is missing
- Anything that increases maintenance burden

Recommend what to remove or defer. Be ruthless.
```

Extremely powerful for solo devs.

---

### 9. Make It Feel Premium

```
Without adding new features:
- Improve perceived quality
- Improve feedback, animations, microcopy
- Improve empty states and error handling

Provide exact text, UI tweaks, or logic changes.
Focus on details users feel but can't articulate.
```

Often the highest ROI prompt.

---

### 10. If This Was a Startup

```
Assume this app must make £500/month within 90 days.

Define:
- Target user (be specific)
- Core pain solved
- Why this beats alternatives

Then suggest the fastest path to that outcome.
```

Forces focus and realism.

---

### 11. Session State Summary

```
Summarise the current state of this project for the next work session:

Include:
- What was completed this session
- What's in progress or partially done
- Key decisions made and why
- Known issues or tech debt introduced
- Recommended next steps (in priority order)

Format this so a fresh AI session can pick up immediately.
```

Essential for solo devs working across multiple sessions.

---

### 12. Code Health Check

```
Review the codebase for:
- Security vulnerabilities (OWASP top 10)
- Memory leaks or resource cleanup issues
- Error handling gaps
- Inconsistent patterns that will cause bugs later

Fix the most critical issue. Flag others for later.
```

Prevents technical debt from compounding.

---

### 13. Approach Clarification

```
Before implementing, present 2-3 possible approaches for this task.

For each approach:
- Describe the implementation
- List pros and cons
- Estimate complexity (low/medium/high)

Recommend one approach and explain why.
Wait for approval before proceeding.
```

Prevents wasted effort from wrong assumptions. Use for non-trivial tasks.

---

### 14. Content & Data Audit

```
Review all user-facing content and data:
- Is there enough content for the first week of usage?
- Is content quality consistent?
- Are there gaps, duplicates, or errors?

Quantify what exists and what's needed.
Generate content to fill the most critical gap.
```

Apps often fail from content shortage, not feature shortage.

---

### 15. App Store Optimisation

```
Prepare this app for the App Store:

Create:
- App title (max 30 chars, keyword-rich)
- Subtitle (max 30 chars)
- 5 keyword phrases (100 char total)
- Short description (first 2 lines users see)
- Full description with feature bullets

Research competitor keywords and differentiate.
```

Discoverability determines success.

---

## The Meta Rule

Most people ask:
> "What should I build next?"

Better question:
> **"What would prevent this from succeeding?"**

All great autonomous prompts:
- Introduce pressure (time, users, money)
- Force decisions
- Demand artifacts, not opinions

---

## How to Use This Playbook

Recommended flow:
1. Start each session with **#11 (Session State Summary)** from the previous session
2. Run the **Core Autonomy Loop** to identify priority
3. Use **#13 (Approach Clarification)** for complex tasks
4. Pick **1-2 other prompts** based on current needs
5. End session with **#11** again for next time

This document is designed to be reused for **every project**.

---

## Anti-Patterns to Avoid

- **"Do everything without asking"** - Leads to wasted effort on wrong assumptions
- **Open-ended exploration** - "Tell me about..." produces opinions, not artifacts
- **Skipping context** - AI without project context gives generic advice
- **Perfectionism** - Ship something every session, even if small

---

**End of Playbook**
