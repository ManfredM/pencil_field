---
description: Generate an actionable, dependency-ordered tasks.md for the feature based on available design artifacts.
---

# Workflow: speckit.tasks

1. **Context Analysis**:
   - The user has provided an input prompt. Treat this as the primary input for the skill.

2. **Load Skill**:
   - Use the `view_file` tool to read the skill file at: `.agent/skills/speckit.tasks/SKILL.md`

3. **Execute**:
   - Follow the instructions in the `SKILL.md` exactly.
   - Apply the user's prompt as the input arguments/context for the skill's logic.

4. **On Error**:
   - If `plan.md` is missing: Run `/speckit.plan` first
   - If `spec.md` is missing: Run `/speckit.specify` first