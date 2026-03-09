---
description: Execute tests, measure coverage, and report results.
---

// turbo-all

# Workflow: speckit.tester

1. **Context Analysis**:
   - The user may specify test paths, options, or just run all tests.

2. **Load Skill**:
   - Use the `view_file` tool to read the skill file at: `.agent/skills/speckit.tester/SKILL.md`

3. **Execute**:
   - Follow the instructions in the `SKILL.md` exactly.
   - Apply the user's prompt as the input arguments/context for the skill's logic.

4. **On Error**:
   - If no test framework detected: Report "No test framework found. Install Jest, Vitest, Pytest, or similar."
   - If tests fail: Show failure details and suggest fixes
