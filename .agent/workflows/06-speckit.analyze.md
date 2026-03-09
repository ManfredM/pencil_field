---
description: Perform a non-destructive cross-artifact consistency and quality analysis across spec.md, plan.md, and tasks.md after task generation.
---

// turbo-all

# Workflow: speckit.analyze

1. **Context Analysis**:
   - The user has provided an input prompt. Treat this as the primary input for the skill.

2. **Load Skill**:
   - Use the `view_file` tool to read the skill file at: `.agent/skills/speckit.analyze/SKILL.md`

3. **Execute**:
   - Follow the instructions in the `SKILL.md` exactly.
   - Apply the user's prompt as the input arguments/context for the skill's logic.

4. **On Error**:
   - If `spec.md` is missing: Run `/speckit.specify` first
   - If `plan.md` is missing: Run `/speckit.plan` first
   - If `tasks.md` is missing: Run `/speckit.tasks` first
