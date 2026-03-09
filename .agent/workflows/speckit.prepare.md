---
description: Execute the full preparation pipeline (Specify -> Clarify -> Plan -> Tasks -> Analyze) in sequence.
---

# Workflow: speckit.prepare

This workflow orchestrates the sequential execution of the Speckit preparation phase skills (02-06).

1. **Step 1: Specify (Skill 02)**
   - Goal: Create or update the `spec.md` based on user input.
   - Action: Read and execute `.agent/skills/speckit.specify/SKILL.md`.

2. **Step 2: Clarify (Skill 03)**
   - Goal: Refine the `spec.md` by identifying and resolving ambiguities.
   - Action: Read and execute `.agent/skills/speckit.clarify/SKILL.md`.

3. **Step 3: Plan (Skill 04)**
   - Goal: Generate `plan.md` from the finalized spec.
   - Action: Read and execute `.agent/skills/speckit.plan/SKILL.md`.

4. **Step 4: Tasks (Skill 05)**
   - Goal: Generate actional `tasks.md` from the plan.
   - Action: Read and execute `.agent/skills/speckit.tasks/SKILL.md`.

5. **Step 5: Analyze (Skill 06)**
   - Goal: Validate consistency across all design artifacts (spec, plan, tasks).
   - Action: Read and execute `.agent/skills/speckit.analyze/SKILL.md`.
