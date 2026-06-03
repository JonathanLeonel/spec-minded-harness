# spec-minded-harness

A spec-driven development runtime for Claude Code.

## The problem

Coding agents are powerful but operationally chaotic. They drift, over-engineer, and lose context between sessions. The usual fix: better prompts. Only goes so far.

The real fix is structure.

## The philosophy

- Humans define intent. Agents execute bounded work.
- A spec is a contract, not a suggestion.
- The orchestrator thinks. The executor codes. Never mix them.
- Human checkpoints are a feature, not a limitation.

## How it works

Two Claude Code windows. Two distinct roles.

**Orchestrator window** (`{project}-orch/`)  
Product thinking, backlog and spec refinement. Talks to Trello. Produces specs.

**Executor window** (`{project}-code/`)  
Reads the spec. Opens a branch. Writes code. Runs tests. Pushes.

Everything generative runs inside Claude. The only shell work is `git`.

## State machine

```
BACKLOG → REFINED → SPEC READY → CODING → LOCAL REVIEW → PR → DONE
                                                               ↑
                                               FAILURE ← (from anywhere)
```

| State        | Owner                  |
| ------------ | ---------------------- |
| BACKLOG      | Human                  |
| REFINED      | Human + Orchestrator   |
| SPEC READY   | Human                  |
| CODING       | Executor agent         |
| LOCAL REVIEW | Human (local testing)  |
| PR           | Human / async reviewer |
| DONE         | Human                  |
| FAILURE      | Human (any stage)      |

## Actions

| Command   | What happens                                          |
| --------- | ----------------------------------------------------- |
| `setup`   | Configure Trello board from URL, run once on init     |
| `add`     | Create a card with just a title in BACKLOG            |
| `refine`  | Discuss and populate the first card (or a given ID)   |
| `spec`    | Write the formal spec to `{code-repo}/specs/`         |
| `execute` | Prepare executor handoff: branch, spec path, context  |
| `push`    | Commit, push, open PR                                 |
| `success` | Move card to DONE                                     |
| `failure` | Move card to FAILED, keep branch, log a learning card |

## Setup

1. Use this repo as a template on GitHub
2. Run the init script from your repos folder:
   ```bash
   spec-minded-harness/scripts/init.sh my-project
   ```
3. Open `my-project/my-project-orch/` in Claude Code
4. Run `setup https://trello.com/b/xxxxx/my-board` — the agent configures the board ID automatically
5. Done — start with `add`

## Structure

```
spec-minded-harness/       ← this repo (public template)
{project}-orch/            ← your orchestrator instance (private)
{project}-code/            ← your actual project (existing or new)
```

## Ideas worth building

**Provider-agnostic state management**  
Abstract the Trello integration behind an interface so state management can be swapped for Jira, SQLite, JSON files, or any other backend without changing the workflow.

**Eval suite**  
Automated end-to-end tests that simulate the full workflow — happy path and failure path — using the Anthropic SDK. Validates that agent behavior matches the spec on every change to the templates.

**Mutation testing**  
Include mutation testing as part of the `execute` quality gates, so the harness validates test quality, not just coverage.

**Git worktree isolation**  
Run each task in an isolated git worktree, preventing side effects between concurrent executions and making rollbacks trivial.

**Run persistence**  
Log each run: prompts, outputs, diffs, decisions. For debugging, retrospective analysis, and future eval training.

**Spec templates**  
Predefined spec templates for common task types: bug fix, new feature, refactor, API endpoint. Reduces the time from `refine` to `spec`.

**`npx create-spec-minded`**  
Publish as an npm package so bootstrapping a new project is a single command without needing to clone the repo manually.

---

Inspired by real-world spec-driven workflows.
