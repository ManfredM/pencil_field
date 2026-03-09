---
description: Challenge the specification with Socratic questioning to identify logical gaps, unhandled edge cases, and robustness issues.
---

// turbo-all

# Workflow: speckit.quizme

1. **Context Analysis**:
   - The user has provided an input prompt. Treat this as the primary input for the skill.

2. **Load Skill**:
   - Use the `view_file` tool to read the skill file at: `.agent/skills/speckit.quizme/SKILL.md`

3. **Execute**:
   - Follow the instructions in the `SKILL.md` exactly.
   - Apply the user's prompt as the input arguments/context for the skill's logic.

4. **On Error**:
   - If required files don't exist, inform the user which prerequisite workflow to run first (e.g., `/speckit.specify` to create `spec.md`).
