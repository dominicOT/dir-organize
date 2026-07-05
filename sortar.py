import os
import shutil
import argparse
from pathlib import Path




FILE_TYPES = {
    "Imgs": ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.svg', '.bmp'],
    "Audio": ['.mp3', '.wav', '.aac', '.flac', '.ogg', '.m4a'],
    "Videos": ['.mp4', '.mkv', '.avi', '.mov', '.wmv', '.webm', '.flv'],
    "PDFs": ['.pdf'],
    "Docs": ['.docx', '.doc'],
    "Spreadsheets": ['.xlsx', '.xls', '.csv'],
    "JSONs": ['.json'],
    "7Zips": ['.zip', '.tar', '.tar.gz', '.rar', '.7z', '.gz'],
    "Python_Scripts": ['.py'],
    "Web": ['.html', '.htm', 'xml'],
    "TXTs": ['.txt', '.md'],
    "Secrets": ['.env', '.env.example']
}


EXTENSION_MAP = {ext: folder for folder, exts in FILE_TYPES.items() for ext in exts}

def organize_downloads(target_dir):
    target_path = Path(target_dir).resolve()
    
    if not target_path.is_dir():
        print(f"Error: directory '{target_dir}' existeth not.")
        return

    print(f"Organizing in '{target_path}'...\n")
    moved_count = 0

    # iterdir() - (not recursive), only top level
    for item in target_path.iterdir():
        if item.is_dir() or item.name.startswith('.'):
            continue
            
        file_ext = item.suffix.lower()
        
        if file_ext in EXTENSION_MAP:
            folder_name = EXTENSION_MAP[file_ext]
            dest_folder = target_path / folder_name
            
            dest_folder.mkdir(exist_ok=True)
            
            dest_path = dest_folder / item.name
            counter = 1
            while dest_path.exists():
                dest_path = dest_folder / f"{item.stem}_{counter}{item.suffix}"
                counter += 1
            
            try:
                shutil.move(str(item), str(dest_path))
                print(f"Moved: {item.name} -> {folder_name}/")
                moved_count += 1
            except PermissionError:
                print(f"Skipped (Permission Denied): {item.name}")
            except Exception as e:
                print(f"Error moving {item.name}: {e}")

    print("\n---")
    print(f"Finished! made your life more organized - moved {moved_count} file(s).")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Organize DIR.")
    parser.add_argument("directory", help="PATH.")
    args = parser.parse_args()
    
    organize_downloads(args.directory)
