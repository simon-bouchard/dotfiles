# Global Claude Code Instructions

## Environment
- OS: WSL Ubuntu on Windows
- Shell: zsh + Oh-My-Zsh, tmux
- Editor: Neovim with Pyright (LSP) and Ruff (format + lint on save)
- Python tooling: uv for new projects, conda or pip may be present in existing ones
- Do not suggest pip if uv is available in the project

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
- Each new file must begin with:
  ```
  # path/to/file/from/project/root
  """
  Short 1–3 line docstring explaining the file's purpose.
  """
  ```
- Docstring comments on classes and functions, avoid inline comments unless necessary
- You may create a README.md when relevant
- Do not create explanation or summary files (implementation_notes.md, explanation.txt, etc.)
  All rationale belongs in the chat, not in files

## Behaviour
- No emojis in code or files
- When uncertain about scope, ask before implementing
- Prefer editing existing code over adding new abstractions
- Do not suggest pre-commit — it is not used in this workflow
