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
BACKLOG → REFINED → SPEC READY → CODING → LOCAL REVIEW → PR → DONE
                                                               ↑
                                               FAILURE ← (from anywhere)
```

| State        | Owner                  |
| ------------ | ---------------------- |
| BACKLOG      | —                      |
| REFINED      | Human + Orchestrator   |
| SPEC READY   | Human                  |
| CODING       | Executor agent         |
| LOCAL REVIEW | Human (local testing)  |
| PR           | Human / async reviewer |
| DONE         | —                      |
| FAILURE      | Human (any stage)      |

## Actions

| Command   | What happens                                          |
| --------- | ----------------------------------------------------- |
| `setup`   | Configure Trello board from URL — run once on init    |
| `add`     | Create a card with just a title in BACKLOG            |
| `refine`  | Discuss and populate the first card (or a given ID)   |
| `spec`    | Write the formal spec to `{code-repo}/specs/`         |
| `execute` | Prepare executor handoff — branch, spec path, context |
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

---

Built around [Claude Code](https://claude.ai/code). Inspired by real-world spec-driven workflows.
