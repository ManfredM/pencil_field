---
description: Run the full speckit pipeline from specification to analysis in one command.
---

# Workflow: speckit.all

This meta-workflow orchestrates the complete specification pipeline.

## Pipeline Steps

1. **Specify** (`/speckit.specify`):
   - Use the `view_file` tool to read: `.agent/skills/speckit.specify/SKILL.md`
   - Execute with user's feature description
   - Creates: `spec.md`

2. **Clarify** (`/speckit.clarify`):
   - Use the `view_file` tool to read: `.agent/skills/speckit.clarify/SKILL.md`
   - Execute to resolve ambiguities
   - Updates: `spec.md`

3. **Plan** (`/speckit.plan`):
   - Use the `view_file` tool to read: `.agent/skills/speckit.plan/SKILL.md`
   - Execute to create technical design
   - Creates: `plan.md`

4. **Tasks** (`/speckit.tasks`):
   - Use the `view_file` tool to read: `.agent/skills/speckit.tasks/SKILL.md`
   - Execute to generate task breakdown
   - Creates: `tasks.md`

5. **Analyze** (`/speckit.analyze`):
   - Use the `view_file` tool to read: `.agent/skills/speckit.analyze/SKILL.md`
   - Execute to validate consistency
   - Output: Analysis report

## Usage

```
/speckit.all "Build a user authentication system with OAuth2 support"
```

## On Error

If any step fails, stop the pipeline and report:
- Which step failed
- The error message
- Suggested remediation (e.g., "Run `/speckit.clarify` to resolve ambiguities before continuing")
