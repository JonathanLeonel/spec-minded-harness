# spec-minded-harness

A spec-driven development runtime for Claude Code.

## The problem

Coding agents are powerful but operationally chaotic. They drift, over-engineer, and lose context between sessions. The usual fix — better prompts — only goes so far.

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
BACKLOG → REFINING → READY → EXECUTING → REVIEW → PR → MERGED → DEPLOYED → DONE
                                                    ↘
                                                  FAILED
```

| State     | Owner                  |
| --------- | ---------------------- |
| BACKLOG   | —                      |
| REFINING  | Human + Orchestrator   |
| READY     | Human                  |
| EXECUTING | Executor agent         |
| REVIEW    | Human (local testing)  |
| PR        | Human / async reviewer |
| MERGED    | CI/CD                  |
| DEPLOYED  | CI/CD                  |
| DONE      | —                      |
| FAILED    | Human                  |

## Actions

| Command   | What happens                                          |
| --------- | ----------------------------------------------------- |
| `add`     | Create a card with just a title in BACKLOG            |
| `refine`  | Discuss and populate the first card (or a given ID)   |
| `scope`   | Write the formal spec to `{code-repo}/.claude/specs/` |
| `execute` | Prepare executor handoff — branch, spec path, context |
| `push`    | Commit, push, open PR                                 |
| `success` | Move card to DONE                                     |
| `failure` | Move card to FAILED, keep branch, log a learning card |

## Setup

1. Use this repo as a template on GitHub
2. Edit `config.yaml` (rename from `config.template.yaml`):
   - Project name
   - Path to your code repo
   - Trello board ID
3. Open `{project}-orch/` in Claude Code — the agent knows what to do

## Structure

```
spec-minded-harness/       ← this repo (public template)
{project}-orch/            ← your orchestrator instance (private)
{project}-code/            ← your actual project (existing or new)
```

---

Built around [Claude Code](https://claude.ai/code). Inspired by real-world spec-driven workflows.
