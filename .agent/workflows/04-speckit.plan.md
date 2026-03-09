---
description: Execute the implementation planning workflow using the plan template to generate design artifacts.
---

# Workflow: speckit.plan

1. **Context Analysis**:
   - The user has provided an input prompt. Treat this as the primary input for the skill.

2. **Load Skill**:
   - Use the `view_file` tool to read the skill file at: `.agent/skills/speckit.plan/SKILL.md`

3. **Execute**:
   - Follow the instructions in the `SKILL.md` exactly.
   - Apply the user's prompt as the input arguments/context for the skill's logic.

4. **On Error**:
   - If `spec.md` is missing: Run `/speckit.specify` first to create the feature specification