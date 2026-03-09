---
description: Create or update the feature specification from a natural language feature description.
---

# Workflow: speckit.specify

1. **Context Analysis**:
   - The user has provided an input prompt. Treat this as the primary input for the skill.
   - This is typically the starting point of a new feature.

2. **Load Skill**:
   - Use the `view_file` tool to read the skill file at: `.agent/skills/speckit.specify/SKILL.md`

3. **Execute**:
   - Follow the instructions in the `SKILL.md` exactly.
   - Apply the user's prompt as the feature description for the skill's logic.

4. **On Error**:
   - If no feature description provided: Ask the user to describe the feature they want to specify
