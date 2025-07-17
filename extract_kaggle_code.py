import os, json, glob, time
import pyperclip

# Update this path for your system (Windows Downloads path in WSL)
download_dir = "/mnt/c/Users/simon/Downloads"
delete_after_copy = True  # Set to False if you want to keep the file

# Find the most recent .ipynb file
notebooks = sorted(glob.glob(os.path.join(download_dir, "*.ipynb")), key=os.path.getmtime, reverse=True)
if not notebooks:
    print("❌ No .ipynb files found.")
    exit()

target = notebooks[0]
time.sleep(1)  # Allow time for file download to complete

# Load notebook
try:
    with open(target, "r", encoding="utf-8") as f:
        nb = json.load(f)
except Exception as e:
    print(f"❌ Failed to load notebook: {e}")
    exit()

# Extract code cells
blocks = []
for cell in nb.get('cells', []):
    if cell.get('cell_type') == 'code':
        text = "".join(cell.get('source', [])).strip()
        if text:
            blocks.append(f"```python\n{text}\n```")

if not blocks:
    print("⚠️ No code cells found.")
    exit()

result = "\n\n".join(blocks)

# Copy to clipboard
try:
    pyperclip.copy(result)
    print(f"✅ Copied {len(blocks)} code cells from: {os.path.basename(target)}")
except Exception as e:
    print(f"⚠️ Failed to copy to clipboard: {e}")
    print("📄 Showing preview instead:\n")
    print(result[:500])

# Delete the file
if delete_after_copy:
    try:
        os.remove(target)
        print(f"🗑️ Deleted: {os.path.basename(target)}")
    except Exception as e:
        print(f"⚠️ Could not delete file: {e}")
