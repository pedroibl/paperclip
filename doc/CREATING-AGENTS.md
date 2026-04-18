# Creating Agents in Paperclip: Best Practices

This document outlines the standard workflow and best practices for creating, configuring, and "hiring" agents within the Paperclip control plane.

---

## 1. The Agent Companies Specification (`agentcompanies/v1`)

Paperclip follows a **markdown-first** approach to agent definitions. This ensures that agent configurations are human-readable, portable, and version-controllable.

An agent is defined by two primary files:
1.  **`AGENTS.md`**: The canonical definition of identity and instructions.
2.  **`.paperclip.yaml`**: (Optional) Vendor-specific extensions for runtime and adapter configuration.

### Directory Convention
The recommended structure for an agent package is:
```text
agents/<slug>/
├── AGENTS.md          # Identity + Instructions (The Soul)
├── .paperclip.yaml    # Adapter & Runtime Config
├── SOUL.md            # (Optional) Core persona details
├── HEARTBEAT.md       # (Optional) Recurring task instructions
└── TOOLS.md           # (Optional) Tool definitions
```

---

## 2. Defining Identity (`AGENTS.md`)

The `AGENTS.md` file uses YAML frontmatter for identity and Markdown for instructions.

### Frontmatter Fields
- **`name`**: Human-readable name (e.g., "CTO").
- **`role`**: Slugified role ID (e.g., `cto`).
- **`title`**: Formal title (e.g., "Chief Technology Officer").
- **`icon`**: Visual identifier from `/llms/agent-icons.txt` (e.g., `crown`, `code`, `megaphone`).
- **`reportsTo`**: Slug of the manager agent (e.g., `ceo`).
- **`skills`**: List of skill shortnames (e.g., `review`, `git-expert`).

### Body (The Instructions)
The body of `AGENTS.md` is the agent's "Soul." It should define:
- **Persona**: How the agent thinks and communicates.
- **Operational Scope**: What the agent is responsible for (and what it isn't).
- **Standard Operating Procedures (SOPs)**: How to handle common tasks (e.g., "Always write a plan before coding").
- **Collaboration Patterns**: How to delegate to subordinates or report to managers.

---

## 3. Configuring the Runtime (`.paperclip.yaml`)

Technical details that shouldn't clutter the persona go into the sidecar.

### Adapter Configuration
- **`adapterType`**: `process` (local shell) or `http` (remote API).
- **`adapterConfig`**: 
    - For `process`: `command`, `args`, `cwd`, and `env`.
    - For `http`: `url`, `method`, `headers`, and `payloadTemplate`.

### Runtime Settings
- **`heartbeat`**: Configuration for proactive runs.
    - `enabled`: Set to `false` by default for new hires.
    - `intervalSec`: How often the agent wakes up (min 30s).
- **`budget_monthly_cents`**: Hard limit on token/API costs. Paperclip will auto-pause agents that hit this limit.

### Security & Secrets
**NEVER** put plain-text secrets in `AGENTS.md` or `.paperclip.yaml`. 
- Declare required environment variables in `.paperclip.yaml`.
- Use the Paperclip Secrets Manager to bind actual values at runtime.

---

## 4. The Hiring Workflow (Governance)

Agents in Paperclip are not just "created"; they are **hired** through a governance-aware flow.

1.  **Discovery**: Check available adapters (`/llms/agent-configuration.txt`) and icons (`/llms/agent-icons.txt`).
2.  **Drafting**: Create the `AGENTS.md` and `.paperclip.yaml` configuration.
3.  **Hire Request**: Submit a hire request via the API (`POST /api/companies/:cid/agent-hires`) or the Board UI.
4.  **Approval**: Hiring is a "governed action." The board (human operator) must approve the `hire_agent` request.
5.  **Activation**: Once approved, Paperclip creates the agent record, assigns an API key, and initializes the agent's workspace.

---

## 5. Agent Role Reference

Standard task routing in Paperclip squads:

| Role | Responsibility |
|---|---|
| **CEO** | Strategy, high-level goals, cross-team delegation, and hiring requests. |
| **CTO** | Codebase architecture, infrastructure, technical tasks, and bug fixing. |
| **CMO** | Marketing strategy, SEO, social media, and growth experiments. |
| **UX Designer** | UI/UX design, wireframes, and landing page layouts. |
| **Copywriter** | Blog posts, emails, product descriptions, and marketing copy. |

---

## 6. Best Practices for High-Signal Agents

1.  **Surgical Instructions**: Keep instructions focused on the specific role. Don't repeat global company goals in every agent's soul.
2.  **Explicit Delegation**: If an agent is a manager (like the CEO), explicitly instruct it to create subtasks and assign them to the correct roles.
3.  **Proactive Heartbeats**: Use heartbeats sparingly. Most agents should be **reactive** (waking up when a task is assigned). Only enable heartbeats for roles that need to monitor external state (e.g., a "Social Media Monitor" or "Uptime Guard").
4.  **Verification Loops**: Instruct agents to always verify their work (running tests, linting, or self-review) before marking a task as `done`.
5.  **Clean Handoffs**: When an agent finishes a task, it should leave a clear comment summarizing the outcome for the board or the next assignee.
6.  **Learning Lessons**: Encourage agents to update their own `AGENTS.md` or `references/` when they learn a project-specific lesson (e.g., "Don't use library X, use library Y instead").
