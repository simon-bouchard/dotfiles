# Global Claude Code Instructions

## Environment
@~/.claude/CLAUDE.local.md
- Shell: zsh + Oh-My-Zsh, tmux
- Editor: Neovim with Pyright (LSP) and Ruff (format + lint on save)
- Python tooling: uv for new projects, conda or pip may be present in existing ones
- Do not suggest pip if uv is available in the project

## Prose Style
Never use em dashes, in any language.
Keep tickets, messages and PR replies short by default; expand only when asked.
Text meant to be copied (suggested comments, replies, messages) must start at column 0: no
indentation, no blockquote, not nested under a list item, so it pastes without leading spaces.

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
- Cap any comment at 2 lines max, in any language. Longer rationale belongs in the chat
  or PR notes, not the code
- You may create or update README.md, CHANGELOG.md and CLAUDE.md when relevant
- Changelog entries: one line per ticket saying what changed, not how. Aim for 5 to 15 words,
  about 25 max as a guideline; a larger ticket may need a little more.
  Add a second line only for an action the consumer must take (new slot, utter, setting).
  No internals, edge cases, known limitations or rationale: those go in the PR notes.
  Match the length of the surrounding entries, e.g.
  `- ([KEY-123](url)) Record the driver added from the add/change vehicle form`
- Do not create explanation or summary files (implementation_notes.md, explanation.txt, etc.)
  All rationale belongs in the chat, not in files

## Behaviour
- No emojis in code or files
- When uncertain about scope, ask before implementing
- "Investigate", "look at", "check", "explain", a question or a pasted log means read-only:
  report findings, and edit no code, docs, knowledge base or tickets until I say go.
  Scratchpad files and temporary edits needed to investigate (debug prints, probes) are fine;
  revert the temporary ones before reporting.
- Prefer editing existing code over adding new abstractions
- Ask for approval before any git operation that changes history or reaches a remote:
  commit, push, merge, rebase, reset, cherry-pick, tag, branch deletion, force operations
- Never add a Co-Authored-By or other Claude attribution line to commit messages or PR descriptions
- For simple read-only lookups (grep, find, cat, ls, etc.), avoid piping or chaining
  (`|`, `&&`, `;`, `$()`, backticks) unless actually necessary — compound commands
  trigger a permission prompt even when every part is read-only. Prefer the dedicated
  Grep/Glob/Read tools, or a single plain command, instead.
