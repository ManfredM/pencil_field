---
description: Execute the implementation plan by processing and executing all tasks defined in tasks.md
---

# Workflow: speckit.implement

1. **Context Analysis**:
   - The user has provided an input prompt. Treat this as the primary input for the skill.

2. **Load Skill**:
   - Use the `view_file` tool to read the skill file at: `.agent/skills/speckit.implement/SKILL.md`

3. **Execute**:
   - Follow the instructions in the `SKILL.md` exactly.
   - Apply the user's prompt as the input arguments/context for the skill's logic.

4. **On Error**:
   - If `tasks.md` is missing: Run `/speckit.tasks` first
   - If `plan.md` is missing: Run `/speckit.plan` first
   - If `spec.md` is missing: Run `/speckit.specify` first
