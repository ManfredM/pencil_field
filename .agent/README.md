# 🚀 Spec-Kit: Antigravity Skills & Workflows

> **The Event Horizon of Software Quality.**
> *Adapted for Google Antigravity IDE from [github/spec-kit](https://github.com/github/spec-kit).*
> *Version: 1.1.0*

---

## 🌟 Overview

Welcome to the **Antigravity Edition** of Spec-Kit. This system is architected to empower your AI pair programmer (Antigravity) to drive the entire Software Development Life Cycle (SDLC) using two powerful mechanisms: **Workflows** and **Skills**.

### 🔄 Dual-Mode Intelligence
In this edition, Spec-Kit commands have been split into two interactive layers:

1.  **Workflows (`/command`)**: High-level orchestrations that guide the agent through a series of logical steps. **The easiest way to run a skill is by typing its corresponding workflow command.**
2.  **Skills (`@speckit.name`)**: Packaged agentic capabilities. Mentions of a skill give the agent immediate context and autonomous "know-how" to execute the specific toolset associated with that phase.

> **To understand the power of Skills in Antigravity, read the docs here:**
> [https://antigravity.google/docs/skills](https://antigravity.google/docs/skills)

---

## 🛠️ Installation

To enable these agent capabilities in your project:

1.  **Add the folder**: Drop the `.agent/` folder into the root of your project workspace.
2.  **That's it!** Antigravity automatically detects the `.agent/skills` and `.agent/workflows` directories. It will instantly gain the ability to perform Spec-Driven Development.

> **💡 Compatibility Note:** This toolkit is fully compatible with **Claude Code**. To use it with Claude, simply rename the `.agent` folder to `.claude`. The skills and workflows will function identically.

---

## 🏗️ The Architecture

The toolkit is organized into modular components that provide both the logic (Scripts) and the structure (Templates) for the agent.

```text
.agent/
├── skills/                  # @ Mentions (Agent Intelligence)
│   ├── speckit.analyze      # Consistency Checker
│   ├── speckit.checker      # Static Analysis Aggregator
│   ├── speckit.checklist    # Requirements Validator
│   ├── speckit.clarify      # Ambiguity Resolver
│   ├── speckit.constitution # Governance Manager
│   ├── speckit.diff         # Artifact Comparator
│   ├── speckit.implement    # Code Builder (Anti-Regression)
│   ├── speckit.migrate      # Legacy Code Migrator
│   ├── speckit.plan         # Technical Planner
│   ├── speckit.quizme       # Logic Challenger (Red Team)
│   ├── speckit.reviewer     # Code Reviewer
│   ├── speckit.specify      # Feature Definer
│   ├── speckit.status       # Progress Dashboard
│   ├── speckit.tasks        # Task Breaker
│   ├── speckit.taskstoissues# Issue Tracker Syncer
│   ├── speckit.tester       # Test Runner & Coverage
│   └── speckit.validate     # Implementation Validator
│
├── workflows/               # / Slash Commands (Orchestration)
│   ├── 00-speckit.all.md           # Full Pipeline
│   ├── 01-speckit.constitution.md  # Governance
│   ├── 02-speckit.specify.md       # Feature Spec
│   ├── ... (Numbered 00-11)
│   ├── speckit.prepare.md          # Prep Pipeline
│   └── util-speckit.*.md           # Utilities
│
└── scripts/                 # Shared Bash Core (Kinetic logic)
```

---

## 🗺️ Mapping: Commands to Capabilities

| Phase | Workflow Trigger | Antigravity Skill | Role |
| :--- | :--- | :--- | :--- |
| **Pipeline** | `/00-speckit.all` | N/A | Runs the full SDLC pipeline. |
| **Governance** | `/01-speckit.constitution` | `@speckit.constitution` | Establishes project rules & principles. |
| **Definition** | `/02-speckit.specify` | `@speckit.specify` | Drafts structured `spec.md`. |
| **Ambiguity** | `/03-speckit.clarify` | `@speckit.clarify` | Resolves gaps post-spec. |
| **Architecture** | `/04-speckit.plan` | `@speckit.plan` | Generates technical `plan.md`. |
| **Decomposition** | `/05-speckit.tasks` | `@speckit.tasks` | Breaks plans into atomic tasks. |
| **Consistency** | `/06-speckit.analyze` | `@speckit.analyze` | Cross-checks Spec vs Plan vs Tasks. |
| **Execution** | `/07-speckit.implement` | `@speckit.implement` | Builds implementation with safety protocols. |
| **Quality** | `/08-speckit.checker` | `@speckit.checker` | Runs static analysis (Linting, Security, Types). |
| **Testing** | `/09-speckit.tester` | `@speckit.tester` | Runs test suite & reports coverage. |
| **Review** | `/10-speckit.reviewer` | `@speckit.reviewer` | Performs code review (Logic, Perf, Style). |
| **Validation** | `/11-speckit.validate` | `@speckit.validate` | Verifies implementation matches Spec requirements. |
| **Preparation** | `/speckit.prepare` | N/A | Runs Specify -> Analyze sequence. |
| **Checklist** | `/util-speckit.checklist` | `@speckit.checklist` | Generates feature checklists. |
| **Diff** | `/util-speckit.diff` | `@speckit.diff` | Compares artifact versions. |
| **Migration** | `/util-speckit.migrate` | `@speckit.migrate` | Port existing code to Spec-Kit. |
| **Red Team** | `/util-speckit.quizme` | `@speckit.quizme` | Challenges logical flaws. |
| **Status** | `/util-speckit.status` | `@speckit.status` | Shows feature completion status. |
| **Tracking** | `/util-speckit.taskstoissues`| `@speckit.taskstoissues`| Syncs tasks to GitHub/Jira/etc. |

---

## 🛡️ The Quality Assurance Pipeline

The following skills are designed to work together as a comprehensive defense against regression and poor quality. Run them in this order:

| Step | Skill | Core Question | Focus |
| :--- | :--- | :--- | :--- |
| **1. Checker** | `@speckit.checker` | *"Is the code compliant?"* | **Syntax & Security**. Runs compilation, linting (ESLint/GolangCI), and vulnerability scans (npm audit/govulncheck). Catches low-level errors first. |
| **2. Tester** | `@speckit.tester` | *"Does it work?"* | **Functionality**. Executes your test suite (Jest/Pytest/Go Test) to ensure logic performs as expected and tests pass. |
| **3. Reviewer** | `@speckit.reviewer` | *"Is the code written well?"* | **Quality & Maintainability**. Analyzes code structure for complexity, performance bottlenecks, and best practices, acting as a senior peer reviewer. |
| **4. Validate** | `@speckit.validate` | *"Did we build the right thing?"* | **Requirements**. Semantically compares the implementation against the defined `spec.md` and `plan.md` to ensure all feature requirements are met. |

> **🤖 Power User Tip:** You can amplify this pipeline by creating a custom **Claude Code (MCP) Server** or subagent that delegates heavy reasoning to **Gemini Pro 3** via the `gemini` CLI.
>
> *   **Use Case:** Bind the `@speckit.validate` and `@speckit.reviewer` steps to Gemini Pro 3.
> *   **Benefit:** Gemini's 1M+ token context and reasoning capabilities excel at analyzing the full project context against the Spec, finding subtle logical flaws that smaller models miss.
> *   **How:** Create a wrapper script `scripts/gemini-reviewer.sh` that pipes the `tasks.md` and codebase to `gemini chat`, then expose this as a tool to Claude.

---

---

## 🏗️ The Design & Management Pipeline

These workflows function as the "Control Plane" of the project, managing everything from idea inception to status tracking.

| Step | Workflow | Core Question | Focus |
| :--- | :--- | :--- | :--- |
| **1. Preparation** | `/speckit.prepare` | *"Are we ready?"* | **The Macro-Workflow**. Runs Skills 02–06 (Specify $\to$ Clarify $\to$ Plan $\to$ Tasks $\to$ Analyze) in one sequence to go from "Idea" to "Ready to Code". |
| **2. Migration** | `/util-speckit.migrate` | *"Can we import?"* | **Onboarding**. Reverse-engineers existing code into `spec.md`, `plan.md`, and `tasks.md`. |
| **3. Red Team** | `/util-speckit.quizme` | *"What did we miss?"* | **Hardening**. Socratic questioning to find logical gaps in your specification before you plan. |
| **4. Export** | `/util-speckit.taskstoissues` | *"Who does what?"* | **Handoff**. Converts your `tasks.md` into real GitHub/Jira issues for the team. |
| **5. Status** | `/util-speckit.status` | *"Are we there yet?"* | **Tracking**. Scans all artifacts to report feature completion percentage. |
| **6. Utilities** | `/util-speckit.diff` <br> `/util-speckit.checklist` | *"What changed?"* | **Support**. View artifact diffs or generate quick acceptance checklists. |

### 🔄 The Design Sequence

**Stage 1: Inception**
*   *Legacy Project?* $\to$ Run **`/util-speckit.migrate`**.
*   *New Feature?* $\to$ Run **`/speckit.prepare`**.

**Stage 2: Hardening**
*   Run **`/util-speckit.quizme`** to catch edge cases.
*   Run **`/speckit.prepare`** again to regenerate the Plan based on restricted specs.

**Stage 3: Handoff**
*   Run **`/util-speckit.taskstoissues`** to sync with your board.

---

## 🚀 Getting Started in Antigravity

Once the `.agent` folder is present, you can talk to your agent as a partner. You can trigger a full process using a slash command or reference a specific capability using a skill mention.

**Example Conversation:**

> **Developer**: "**/02-speckit.specify** Add a real-time notification system using WebSockets."
>
> **Antigravity**: "Understood. Executing the **@speckit.specify** skill. Creating feature branch `005-notifications` and drafting the initial specification..."
> *(Antigravity creates branch, drafts spec.md)*
>
> **Antigravity**: "Specification ready. I've identified some ambiguity in the reconnection strategy. Should I use **@speckit.clarify** to resolve this?"
>
> **Developer**: "Yes, use **@speckit.clarify**."
> *(Antigravity executes the skill logic, interviewing the developer and updating the spec)*
>
> **Antigravity**: "The spec is now robust. I'm ready to trigger **/04-speckit.plan** and **/05-speckit.tasks** to prepare for implementation."

---

## 🏆 Best Practices for Antigravity

To get the most out of this system, follow these **Spec-Driven Development (SDD)** rules:

### 1. The Constitution is King 👑
**Never skip `/01-speckit.constitution`.**
*   This file is the "Context Window Anchor" for the AI.
*   It prevents hallucinations about tech stack (e.g., "Don't use jQuery" or "Always use TypeScript strict mode").
*   **Tip:** If Antigravity makes a style mistake, don't just fix the code—update the Constitution so it never happens again.

### 2. The Layered Defense 🛡️
Don't rush to code. The workflow exists to catch errors *cheaply* before they become expensive bugs.
*   **Ambiguity Layer**: `/03-speckit.clarify` catches misunderstandings.
*   **Logic Layer**: `/util-speckit.quizme` catches edge cases.
*   **Consistency Layer**: `/06-speckit.analyze` catches gaps between Spec and Plan.

### 3. The 15-Minute Rule ⏱️
When generating `tasks.md` (Skill 05), ensure tasks are **atomic**.
*   **Bad Task**: "Implement User Auth" (Too big, AI will get lost).
*   **Good Task**: "Create `User` Mongoose schema with email validation" (Perfect).
*   **Rule of Thumb**: If a task takes Antigravity more than 3 tool calls to finish, it's too big. Break it down.

### 4. "Refine, Don't Rewind" ⏩
If you change your mind mid-project:
1.  Don't just edit the code.
2.  Edit the `spec.md` to reflect the new requirement.
3.  Run `/util-speckit.diff` to see the drift.
4.  This keeps your documentation alive and truthful.

---

## 🧩 Adaptation Notes

*   **Skill-Based Autonomy**: Mentions like `@speckit.plan` trigger the agent's internalized understanding of how to perform that role.
*   **Shared Script Core**: All logic resides in `.agent/scripts/bash` for consistent file and git operations.
*   **Agent-Native**: Designed to be invoked via Antigravity tool calls and reasoning rather than just terminal strings.

---
*Built with logic from [Spec-Kit](https://github.com/github/spec-kit). Powered by Antigravity.*
