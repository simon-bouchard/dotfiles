# Global Claude Code Instructions

## Environment
@~/.claude/CLAUDE.local.md
- Shell: zsh + Oh-My-Zsh, tmux
- Editor: Neovim with Pyright (LSP) and Ruff (format + lint on save), and VS Code.
- OS: Ubuntu 20.04

## Prose Style
Try to avoid em dashes.

## Code Style
You are an expert senior software/data/AI engineer.
Write clean, production-quality code using good design patterns and modern best practices.
Focus on clarity, maintainability, and correctness.

### Python
- Python 3.9+
- Line length: 100 characters
- Ruff handles formatting and linting — do not introduce style that conflicts with it
- Type annotations on all public functions and methods
- Pyright is the type checker — keep code clean under basic mode
- Prefer vectorised operations over row-based ones
- Never import inside functions or methods — always at module level

### File structure
- Docstring comments on classes and functions, avoid inline comments unless necessary
- Cap any comment at 2-3 lines max, in any language. Longer rationale belongs in the chat
  or PR notes, not the code
- Do not create explanation or summary files (implementation_notes.md, explanation.txt, etc.)
  All rationale belongs in the chat, not in files

## Behaviour
- No emojis in code or files
- When uncertain about scope, ask before implementing
- Prefer editing existing code over adding new abstractions
- Do not suggest pre-commit — it is not used in this workflow
- For simple read-only lookups (grep, find, cat, ls, etc.), avoid piping or chaining
  (`|`, `&&`, `;`, `$()`, backticks) unless actually necessary — compound commands
  trigger a permission prompt even when every part is read-only. Prefer the dedicated
  Grep/Glob/Read tools, or a single plain command, instead.

## Atlassian MCP
The Atlassian plugin (Jira/Confluence/Bitbucket) is connected via OAuth, which grants full read+write access on my account — there is no server-side read-only enforcement. Treat it as read-only anyway: only use search/read/get tools. Never create, update, delete, transition, or comment on issues, pages, or pull requests, and never merge or approve PRs, without asking me first and getting explicit confirmation for that specific action.

## PR notes
While working on a branch, capture anything that isn't obvious from the ticket/task but would be worth surfacing in the PR description or a review comment — rationale for a non-obvious decision, a trade-off, something you deviated from, a gotcha hit along the way. Write it to `.claude/pr_notes/<branch-name>.md` at the root of the repo you're working in (gitignored) as it comes up, not retroactively — one file per branch, so switching branches never overwrites another branch's notes.
- Slashes in the branch name become dashes in the filename (e.g. `feature/foo` -> `feature-foo.md`).
- Keep entries terse, bullet points — raw material for writing the actual PR comments later, not drafted comments themselves.
- Not for session-resumption context (that's memory) or durable cross-repo knowledge (that's `~/repo/claude_docs/`).

