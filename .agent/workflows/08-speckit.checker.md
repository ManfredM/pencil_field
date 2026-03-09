---
description: Run static analysis tools and aggregate results.
---

// turbo-all

# Workflow: speckit.checker

1. **Context Analysis**:
   - The user may specify paths to check or run on entire project.

2. **Load Skill**:
   - Use the `view_file` tool to read the skill file at: `.agent/skills/speckit.checker/SKILL.md`

3. **Execute**:
   - Follow the instructions in the `SKILL.md` exactly.
   - Apply the user's prompt as the input arguments/context for the skill's logic.

4. **On Error**:
   - If no linting tools available: Report which tools to install based on project type
   - If tools fail: Show raw error and suggest config fixes
