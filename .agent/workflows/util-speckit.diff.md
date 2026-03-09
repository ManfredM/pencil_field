---
description: Compare two versions of a spec or plan to highlight changes.
---

# Workflow: speckit.diff

1. **Context Analysis**:
   - The user has provided an input prompt (optional file paths or version references).

2. **Load Skill**:
   - Use the `view_file` tool to read the skill file at: `.agent/skills/speckit.diff/SKILL.md`

3. **Execute**:
   - Follow the instructions in the `SKILL.md` exactly.
   - Apply the user's prompt as the input arguments/context for the skill's logic.

4. **On Error**:
   - If no files to compare: Use current feature's `spec.md` vs git HEAD
   - If `spec.md` doesn't exist: Run `/speckit.specify` first
