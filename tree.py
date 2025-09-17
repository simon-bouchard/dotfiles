import os
import pyperclip

EXCLUDED = {'.git', '__pycache__', 'node_modules', 'venv', '.mypy_cache', '.pytest_cache', '.idea', '.vscode', '.DS_Store'}

def build_tree(root_path='.', prefix=''):
    lines = []
    entries = sorted([
        entry for entry in os.listdir(root_path)
        if entry not in EXCLUDED
    ])
    for i, entry in enumerate(entries):
        full_path = os.path.join(root_path, entry)
        connector = '└── ' if i == len(entries) - 1 else '├── '
        lines.append(prefix + connector + entry)
        if os.path.isdir(full_path):
            extension = '    ' if i == len(entries) - 1 else '│   '
            lines.extend(build_tree(full_path, prefix + extension))
    return lines

if __name__ == '__main__':
    cwd = os.getcwd()
    tree_lines = [f"📁 Project tree from: {cwd}", ""] + build_tree(cwd)
    result = '\n'.join(tree_lines)
    pyperclip.copy(result)
    print("✅ Project structure copied to clipboard.")

