import json, os, glob
import pyperclip

# Path to your Windows Downloads folder (from WSL)
download_dir = "/mnt/c/Users/simon/Downloads"
notebooks = sorted(glob.glob(os.path.join(download_dir, "*.ipynb")), key=os.path.getmtime, reverse=True)

if not notebooks:
    print("❌ No notebook found in Downloads.")
    exit()

with open(notebooks[0], "r", encoding="utf-8") as f:
    nb = json.load(f)

blocks = []
for cell in nb['cells']:
    if cell['cell_type'] in ('code', 'markdown'):
        text = "".join(cell['source']).strip()
        lang = 'python' if cell['cell_type'] == 'code' else 'markdown'
        blocks.append(f"```{lang}\n{text}\n```")

result = "\n\n".join(blocks)

# Copy to clipboard via pyperclip (requires xclip on WSL)
try:
    pyperclip.copy(result)
    print(f"✅ Copied {len(blocks)} cells from: {os.path.basename(notebooks[0])}")
except pyperclip.PyperclipException:
    print("⚠️ Could not copy to clipboard. Try installing xclip: sudo apt install xclip")
    print(result[:500])  # Show a preview
