# Backlog — spec-minded-harness

Pending improvements. Each entry has enough context to implement without prior conversation.

---

## [ORCH] `status` command

New command in the orch CLAUDE.md, same level as `add`, `refine`, `spec`.

**What it does:** reads current project state and prints a summary.

**Sources to query (in order):**
1. `config.yaml` → project name, code repo path, board_id
2. Trello MCP → card count per column; active card in CODING (id, title, spec path)
3. `{code_repo}/specs/` → active specs (list files)
4. `{code_repo}/specs/done/` → archived specs (count)
5. git (in code repo) → current branch, commits ahead, uncommitted changes, last commit message

**Expected output:**
```
## Status: {project-name}

Pipeline: CODING
Active card: #0003 - Date filter (specs/0003-date-filter.md)
Branch: feat/0003-date-filter (+3 commits, no uncommitted changes)
Last commit: "feat: add DatePicker component"

Backlog: 5 | Refined: 2 | Spec Ready: 1 | Coding: 1 | Done: 8 | Failed: 1
Active specs: 1 | Archived: 8
```

If pipeline is IDLE (no card in CODING/REVIEW/PR):
```
Pipeline: IDLE — next card in Spec Ready: #0004 - Export CSV
```

**Notes:**
- No arguments required
- If no card is in CODING, show the next one in SPEC READY or REFINED
- If git has no remote configured, omit that line silently

---

## [EXECUTOR] Manual commit control

**Problem:** the executor commits autonomously at two points without asking:
1. The "spec commit" at the start of `execute` (only adds the spec `.md` file)
2. During or at the end of implementation

This produces commits with wrong messages and removes control from the user.

**Fix:** in the executor CLAUDE.md, replace any direct `git commit` with a suggestion flow:

1. Run `git add <relevant files>`
2. Show full `git diff --staged`
3. Propose the exact commit command for the user to run, e.g.:
   ```
   ! git commit -m "feat: add InMemoryKBRepository"
   ```
4. Stop. The user runs the command themselves via `!` — the executor never executes the commit.

The user can adjust the message or the staged files before running. The executor never calls `git commit` directly under any circumstance.

Applies to **all** executor commits: spec commit, implementation commits, and archive commit.

**PR base branch:** feature branches always open PRs against `master`, unless the user explicitly specifies a different target at the time of running `push`.

**Commit message format:** `type: message` — no scope in parens, no em dashes, all lowercase.

Allowed types:

| type | when |
|---|---|
| `feat` | new functionality |
| `fix` | bug fix |
| `chore` | tooling, config, deps, structure |
| `docs` | documentation |
| `test` | adding or modifying tests (no logic change) |
| `refactor` | restructuring without behavior change |
| `spec` | reserved — initial spec commit only |

Examples: `feat: add InMemoryKBRepository`, `test: add edge cases for date filter`, `chore: update tsconfig`.

---

## [EXECUTOR] TDD red phase must be a logic failure, not a compile error

**Problem:** when the executor runs the red phase of TDD, the tests currently fail because the file or module doesn't exist yet (compile-time / import error). That's not a real red — it's a setup failure.

**What a valid red looks like:** the file exists, the function/class exists (as a stub that compiles and returns a dummy value), and the tests fail because the expected behavior isn't implemented yet.

**Required flow:**
1. Write the tests first
2. Create the implementation file with stubs — correct signatures, no logic (return `null`, `[]`, `0`, `""`, etc.)
3. Confirm the suite runs and tests fail **due to assertion errors**, not import/compile errors
4. Only then start implementing until green

**Why it matters:** a compile-time red gives false confidence — the test may be wrong, incomplete, or testing the wrong thing. An assertion-level red proves the test is wired up correctly and actually covers the case.

**On test coverage philosophy:** always write failure cases before happy path. A test suite with only happy path gives false confidence — it proves the code works when everything goes right, not that it holds when things go wrong. Required coverage order:
1. What should fail and does fail (empty inputs, k=0, missing data)
2. What should pass and does pass (correct output, correct return value)
3. That collaborators were called the right number of times and with the right arguments — no more, no less

Verify every collaborator in the flow. If `askRag` calls `embedder → repository → generator`, there must be an assertion on each one. A missing assertion means a collaborator can be removed from the implementation and the test still passes.

**On typing mocks in tests:** mocks must be typed against the port interfaces, not with inline object types. This ensures that if a contract changes, TypeScript fails at compile-time before any test runs — which is the first and cheapest red signal. Typing mocks as `{ method: vi.fn() }` defeats static typing in the test suite and breaks the TDD feedback loop.

```typescript
// wrong
let embedder: { embed: ReturnType<typeof vi.fn> };

// correct
let embedder: Embedder;
beforeEach(() => {
  embedder = { embed: vi.fn().mockResolvedValue([1, 0]) } as Embedder;
});
```

**On committing during red:** the executor must NOT commit while tests are red. After showing the failing output, it waits for explicit human validation ("ok, the red looks right") before staging anything. Only once the human confirms the failures are expected does the flow continue toward green.

---

## [EXECUTOR] `sync` command + [ORCH] reminder on `success`

**Problem:** after a PR is merged, the code repo is left on the feature branch with no cleanup. The executor has no signal to return to `master`.

**Fix — executor:** add a `sync` command that:
1. `git checkout master`
2. `git pull`
3. Confirms repo is clean and ready for the next feature

The executor doesn't care whether the merge succeeded or failed — that's handled by the orch `success`/`failure` flow. `sync` just aligns the local repo with remote `master`.

**Fix — orch:** as the last step of the `success` command, remind the user: *"Run `sync` in the code window to return to master."*

This keeps responsibilities clean: orch owns project state (Trello), executor owns repo state (git). Coordination happens through the user, consistent with the existing harness pattern.
