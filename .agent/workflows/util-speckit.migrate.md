---
description: Migrate existing projects into the speckit structure by generating spec.md, plan.md, and tasks.md from existing code.
---

# Workflow: speckit.migrate

1. **Context Analysis**:
   - The user has provided an input prompt (path to analyze, feature name).

2. **Load Skill**:
   - Use the `view_file` tool to read the skill file at: `.agent/skills/speckit.migrate/SKILL.md`

3. **Execute**:
   - Follow the instructions in the `SKILL.md` exactly.
   - Apply the user's prompt as the input arguments/context for the skill's logic.

4. **On Error**:
   - If path doesn't exist: Ask user to provide valid directory path
   - If no code found: Report that no analyzable code was detected
