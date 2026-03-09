---
name: speckit.status
description: Display a dashboard showing feature status, completion percentage, and blockers.
version: 1.0.0
depends-on: []
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Role

You are the **Antigravity Status Reporter**. Your role is to provide clear, actionable status updates on project progress.

## Task

### Outline

Generate a dashboard view of all features and their completion status.

### Execution Steps

1. **Discover Features**:
   ```bash
   # Find all feature directories
   find .specify/features -maxdepth 1 -type d 2>/dev/null || echo "No features found"
   ```

2. **For Each Feature, Gather Metrics**:

   | Artifact | Check | Metric |
   |----------|-------|--------|
   | spec.md | Exists? | Has [NEEDS CLARIFICATION]? |
   | plan.md | Exists? | All sections complete? |
   | tasks.md | Exists? | Count [x] vs [ ] vs [/] |
   | checklists/*.md | All items checked? | Checklist completion % |

3. **Calculate Completion**:
   ```
   Phase 1 (Specify): spec.md exists & no clarifications needed
   Phase 2 (Plan): plan.md exists & complete
   Phase 3 (Tasks): tasks.md exists
   Phase 4 (Implement): tasks.md completion %
   Phase 5 (Validate): validation-report.md exists with PASS
   ```

4. **Identify Blockers**:
   - [NEEDS CLARIFICATION] markers
   - [ ] tasks with no progress
   - Failed checklist items
   - Missing dependencies

5. **Generate Dashboard**:
   ```markdown
   # Speckit Status Dashboard
   
   **Generated**: [timestamp]
   **Total Features**: X
   
   ## Overview
   
   | Feature | Phase | Progress | Blockers | Next Action |
   |---------|-------|----------|----------|-------------|
   | auth-system | Implement | 75% | 0 | Complete remaining tasks |
   | payment-flow | Plan | 40% | 2 | Resolve clarifications |
   
   ## Feature Details
   
   ### [Feature Name]
   
   ```
   Spec:  ████████░░ 80%
   Plan:  ██████████ 100%
   Tasks: ██████░░░░ 60%
   ```
   
   **Blockers**:
   - [ ] Clarification needed: "What payment providers?"
   
   **Recent Activity**:
   - Last modified: [date]
   - Files changed: [list]
   
   ---
   
   ## Summary
   
   - Features Ready for Implementation: X
   - Features Blocked: Y
   - Overall Project Completion: Z%
   ```

6. **Output**:
   - Display in terminal
   - Optionally write to `.specify/STATUS.md`

## Operating Principles

- **Be Current**: Always read latest file state
- **Be Visual**: Use progress bars and tables
- **Be Actionable**: Every status should have a "next action"
- **Be Fast**: Cache nothing, always recalculate
