---
description: Perform code review with actionable feedback and suggestions.
---

# Workflow: speckit.reviewer

1. **Context Analysis**:
   - The user may specify files to review, "staged" for git staged changes, or "branch" for branch diff.

2. **Load Skill**:
   - Use the `view_file` tool to read the skill file at: `.agent/skills/speckit.reviewer/SKILL.md`

3. **Execute**:
   - Follow the instructions in the `SKILL.md` exactly.
   - Apply the user's prompt as the input arguments/context for the skill's logic.

4. **On Error**:
   - If no files to review: Ask user to stage changes or specify file paths
   - If not a git repo: Review current directory files instead
