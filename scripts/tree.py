import os
import argparse
import pyperclip

EXCLUDED = {
    ".git",
    "__pycache__",
    "node_modules",
    "venv",
    ".mypy_cache",
    ".pytest_cache",
    ".idea",
    ".vscode",
    ".DS_Store",
    "results",
	"performance_baselines",
	"backup",
}
EXCLUDED_EXTENSIONS = {".npz", ".pyc"}


def build_tree(root_path=".", prefix="", depth=None, current_depth=0):
    if depth is not None and current_depth >= depth:
        return []

    lines = []
    entries = sorted(
        [
            entry
            for entry in os.listdir(root_path)
            if entry not in EXCLUDED and not any(entry.endswith(ext) for ext in EXCLUDED_EXTENSIONS)
        ]
    )
    for i, entry in enumerate(entries):
        full_path = os.path.join(root_path, entry)
        connector = "└── " if i == len(entries) - 1 else "├── "
        lines.append(prefix + connector + entry)
        if os.path.isdir(full_path):
            extension = "    " if i == len(entries) - 1 else "│   "
            lines.extend(build_tree(full_path, prefix + extension, depth, current_depth + 1))
    return lines


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate project tree")
    parser.add_argument(
        "-w",
        "--write",
        metavar="FILE",
        nargs="?",
        const="tree.txt",
        help="Write to file (default: tree.txt)",
    )
    parser.add_argument(
        "-d",
        "--depth",
        type=int,
        default=None,
        help="Max depth of directories to display (default: unlimited)",
    )
    args = parser.parse_args()

    cwd = os.getcwd()
    tree_lines = [f"📁 Project tree from: {cwd}", ""] + build_tree(cwd, depth=args.depth)
    result = "\n".join(tree_lines)

    if args.write:
        with open(args.write, "w") as f:
            f.write(result)
        print(f"✅ Project structure written to {args.write}")
    else:
        pyperclip.copy(result)
        print("✅ Project structure copied to clipboard.")
