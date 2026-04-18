# GEMINI.md - AI Agent Context

This file documents the environment, security configurations, and operational history of the AI agents within this workspace. Kept in syac with CLAUDE.md — both files contain the same operational knowledge.

---

## 1. Squad Configuration (Company ID: 5a0a40ab-d537-44fc-a594-ad38f4850afe)

| Agent | Role | Full ID |
|-------|------|---------|
| CEO | ceo | `260b3a65-2626-4c86-a561-40d1d064632e` |
| CMO | cmo | `83591b00-aa96-4ac0-9a43-9a87740b542a` |
| CTO | cto | `1df6f2ac-53da-49a1-b917-a8512b796b84` |
| UX Designer | designer | `e62d8d88-56bd-431f-ad54-975ef0e2c0e8` |
| Copywriter | general | `d6415d3c-9f72-474d-89fd-920b03fb4386` |

All agents use the `hermes_local` adapter with model `grok-4-1-fast`.

---

## 2. Security Configuration (Hermes & Tirith)

Agents use the **Hermes** adapter with **Tirith** security scanning. The following are allow-listed in `~/.hermes/config.yaml` to prevent false-positive blocks on local API calls:

- `tirith:curl_pipe_shell` (Security Rule)
- `script execution via -e/-c flag` (Hermes Internal Rule)
- `curl -s http://127.0.0.1:3100/*` (Command/URL)
- `curl -s http://localhost:3100/*` (Command/URL)

`TIRITH_ALLOW_HTTP=1` is set in `~/.hermes/.env` to permit local HTTP traffic.

**Root cause:** Hermes flags `curl | python3` as pipe-to-interpreter regardless of source. Since agents use this pattern to parse local API responses, it must be allow-listed or the agent silently aborts its run.

---

## 3. Project Milestones

### 2026-04-17: Squad Initialization & Security Fix
- **Security Unblock:** Resolved Hermes and Tirith blocking agents from accessing the Paperclip API via `curl | python3`.
- **Environment Setup:** Created all required agent workspace directories to prevent crashes during task execution.
- **Task Start:** Initialized the "Validation Phase" for **Melbourne Print Hub**.
- **Completed MELA-3:** CEO defined the first 5 product listings (Business Cards, A4 Flyers, A3 Posters, Vinyl Banners, Custom Stickers).
- **Agent Activation:** All 5 agents activated via `hire_agent` approval flow after being imported with `pending_approval` status (no approval records existed — resolved by creating and immediately approving approval records via the API).

---

## 4. Workspaces (Persistent Context)

Agent working files and session logs:
```
~/.paperclip/instances/default/workspaces/<agent-id>/
```

Agent instruction files:
```
~/.paperclip/instances/default/companies/5a0a40ab-d537-44fc-a594-ad38f4850afe/agents/<agent-id>/instructions/
```
Key files per agent: `AGENTS.md`, `HEARTBEAT.md`, `SOUL.md`, `TOOLS.md`

---

## 5. Active Goals

| Goal ID | Title | Status |
|---------|-------|--------|
| `f999655b` | Generate 1000 leads by December 2026 | active |
| `70ef5460` | AUTO Marketing (100% social media automated) | active |

---

## 6. Known Issues & Gotchas

### `priority` field is a string enum, not a number
The API validates `priority` as `"critical" | "high" | "medium" | "low"`. Passing a number (e.g. `1`, `2`) returns a 400 validation error.

```bash
# WRONG
"priority": 2

# CORRECT
"priority": "high"
```

### Blocked issues — most common cause
If an agent completes work but exits without marking the issue `done`, Paperclip's recovery system retries once, then escalates to `blocked`. Fix: `PATCH /api/issues/{id}` with `{"status": "done"}` or `{"status": "todo"}` to retry.

### Approval Catch-22 on import
Agents imported externally are created with `pending_approval` status but no approval records. `approval list` returns `[]` and API calls return 500 if you use the wrong company ID. Fix: create a `hire_agent` approval for each agent via `POST /api/companies/{cid}/approvals` with `{"type":"hire_agent","payload":{"agentId":"..."}}`, then approve it via `POST /api/approvals/{id}/approve`.

### Heartbeats are disabled by default
New agents have `heartbeat.enabled: false`. Enable per agent:
```bash
curl -s -X PATCH "http://127.0.0.1:3100/api/agents/{AGENT_ID}" \
  -H "Content-Type: application/json" \
  -d '{"runtimeConfig":{"heartbeat":{"enabled":true,"intervalSec":300,"maxConcurrentRuns":1}}}'
```

---

## 7. Task Routing Reference

| Work type | Assign to |
|-----------|-----------|
| Code, website, APIs, infra, bugs | CTO |
| Marketing, ads, social media, SEO, growth | CMO |
| UX, design, wireframes, landing pages | UX Designer |
| Copy, blog posts, emails, product descriptions | Copywriter |
| Strategy, cross-team, priorities, hiring | CEO |

---

## 8. See Also

Full operator tutorial (tasks, goals, heartbeats, routines):
```
~/Desktop/paperclip-proactive-agents-tutorial.md
```


Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.
