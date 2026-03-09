---
description: Generate a custom checklist for the current feature based on user requirements.
---

# Workflow: speckit.checklist

1. **Context Analysis**:
   - The user has provided an input prompt. Treat this as the primary input for the skill.

2. **Load Skill**:
   - Use the `view_file` tool to read the skill file at: `.agent/skills/speckit.checklist/SKILL.md`

3. **Execute**:
   - Follow the instructions in the `SKILL.md` exactly.
   - Apply the user's prompt as the input arguments/context for the skill's logic.

4. **On Error**:
   - If `spec.md` is missing: Run `/speckit.specify` first to create the feature specification
