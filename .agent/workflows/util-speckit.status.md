---
description: Display a dashboard showing feature status, completion percentage, and blockers.
---

// turbo-all

# Workflow: speckit.status

1. **Context Analysis**:
   - The user may optionally specify a feature to focus on.

2. **Load Skill**:
   - Use the `view_file` tool to read the skill file at: `.agent/skills/speckit.status/SKILL.md`

3. **Execute**:
   - Follow the instructions in the `SKILL.md` exactly.
   - Apply the user's prompt as the input arguments/context for the skill's logic.

4. **On Error**:
   - If no features exist: Report "No features found. Run `/speckit.specify` to create your first feature."
