# Testing spec-minded-harness

Manual checklist for validating the full workflow from scratch.
Run this after significant changes to templates, scripts, or actions.

---

## Prerequisites

- [ ] `gh auth status` — shows active GitHub account
- [ ] `claude --version` — returns a version number
- [ ] `claude mcp list` — shows `trello: ✓ Connected`
- [ ] Trello board has exactly these lists (in order): **Backlog, Refined, Spec Ready, Coding, Local Review, PR, Done, Failure**

---

## Phase 1 — Init

```bash
cd ~/Repos
spec-minded-harness/scripts/init.sh my-project
```

**Verify:**

- [ ] `my-project/` folder created
- [ ] `my-project/my-project-orch/` exists with `CLAUDE.md`, `.gitignore`, `config.yaml`
- [ ] `my-project/my-project-code/` exists with `CLAUDE.md`, `.gitignore`, `specs/`, `specs/done/`
- [ ] `config.yaml` has `name: my-project` and `code_repo: ../my-project-code`
- [ ] Terminal output says to run `setup https://trello.com/b/...`

---

## Phase 2 — Setup (Orchestrator window)

Open `my-project/my-project-orch/` in Claude Code.

Copy and paste your Trello board URL:

```
setup https://trello.com/b/{your-board-short-id}/your-board-name
```

**Verify:**

- [ ] Agent extracts the short ID from the URL
- [ ] Agent finds the board via Trello MCP
- [ ] `config.yaml` updated with the full `board_id` — no manual edit needed
- [ ] Agent confirms board name and ID

---

## Phase 3 — Add

```
add
```

Provide a title when asked, or pass it directly:

```
add "Log Hello Harness! to console"
```

```
add "Create a hello.txt with today's date"
```

```
add "Print current Node.js version on startup"
```

**Verify:**

- [ ] Card created in Trello **Backlog**
- [ ] Agent shows both the full card ID and the short ID (`#1`, `#2`, etc.)

---

## Phase 4 — Refine

```
refine
```

Populate the card with a minimal description, acceptance criteria, and constraints.

**Verify:**

- [ ] Agent discusses and asks questions
- [ ] Trello card updated wth deiscription and acceptance criteria
- [ ] Card moved to **Refined**

---

## Phase 5 — Spec

```
spec
```

**Verify:**

- [ ] Spec file created at `my-project-code/specs/0001-hello-spec-minded-harness.md`
- [ ] Spec has frontmatter with `card_id`, `card_short`, `board_id`
- [ ] Spec body has objective, constraints, acceptance criteria, files likely affected
- [ ] Card moved to **Spec Ready**
- [ ] Agent outputs exactly: `execute specs/0001-...md` and nothing else

---

## Phase 6 — Execute (Executor window)

Open `my-project/my-project-code/` in Claude Code.

```
execute specs/0001-hello-spec-minded-harness.md
```

**Verify:**

- [ ] Agent reads spec frontmatter
- [ ] Card moved to **Coding** in Trello
- [ ] Spec drift check runs — agent lists files to check
- [ ] If no drift: agent presents implementation plan
- [ ] Plan approved → branch `feat/0001-hello-spec-minded-harness` created
- [ ] First commit is the spec file only: `spec: #1 Hello spec-minded-harness`
- [ ] Implementation done
- [ ] Agent reports ready for local review

---

## Phase 7 — Local review

Test the implementation manually.

**Verify:**

- [ ] Feature works as described in the spec
- [ ] No regressions

---

## Phase 8 — Push (Executor window)

```
push
```

**Verify:**

- [ ] Remote check runs
- [ ] If no remote: private GitHub repo created, remote wired up, default branch pushed
- [ ] Feature branch pushed
- [ ] PR opened with correct title and description
- [ ] PR body ends with `🔧 Implemented with spec-minded-harness` — no Claude attribution
- [ ] Spec moved to `specs/done/` and archive commit pushed
- [ ] Card moved to **PR** in Trello

---

## Phase 9 — Success (Orchestrator window)

Merge the PR on GitHub. Then:

```
success
```

**Verify:**

- [ ] Card moved to **Done** in Trello
- [ ] Agent asks if you want to start a new pipeline

---

## Failure path (optional)

At any point during phases 3–8, run `failure` in the active window.

```
failure
```

Provide a reason (e.g. `feature no longer needed`).

**Verify:**

- [ ] Card moved to **Failure** in Trello
- [ ] New learning card created in **Backlog**: `Learning: Hello spec-minded-harness`
- [ ] Learning card has the reason as description
- [ ] Branch name noted in learning card (if branch was created)
- [ ] Agent asks to retry or discard
