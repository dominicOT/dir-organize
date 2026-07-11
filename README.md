# Smart Directory Organizer

A modern, fast, and secure desktop utility built with **Python**, **PySide6**, and **Qt Quick (QML)** that organizes messy directories into clean, categorized folders by file type.

This tool is designed to work exclusively with main directories like `Documents` and `Downloads` (case-sensitive) to prevent accidental sorting of system or development workspace directories.

---

## Features

- **🎨 Premium Dark UI**: Obsidian/Slate dark mode layout built using custom Qt Quick components with micro-animations.
- **⚡ Quick Select Cards**: One-click selection for system `Downloads` and `Documents` folders.
- **📂 Manual Folder Selection**: Standard browser dialog and direct text input support.
- **🛡️ Directory Validation**: Safeguards against invalid paths or folders that do not match the case-sensitive name check (`Documents` or `Downloads`).
- **📟 Live Terminal Logging**: Monospaced activity log showing moved items in real time, with automatic scroll tracking.
- **🧵 Responsive Multithreading**: Background sorting worker keeps the interface interactive and responsive.
- **💻 CLI & Scripting Support**: Standard terminal command execution remains fully supported.

---

## Folder Categories

Files are sorted at the top level of the folder (non-recursively) into the following subfolders based on extension:

| Category | Extensions |
| :--- | :--- |
| **Imgs** | `.jpg`, `.jpeg`, `.png`, `.gif`, `.webp`, `.svg`, `.bmp` |
| **Audio** | `.mp3`, `.wav`, `.aac`, `.flac`, `.ogg`, `.m4a` |
| **Videos** | `.mp4`, `.mkv`, `.avi`, `.mov`, `.wmv`, `.webm`, `.flv` |
| **PDFs** | `.pdf` |
| **Docs** | `.docx`, `.doc` |
| **Spreadsheets** | `.xlsx`, `.xls`, `.csv` |
| **JSONs** | `.json` |
| **7Zips** | `.zip`, `.tar`, `.tar.gz`, `.rar`, `.7z`, `.gz` |
| **Python_Scripts** | `.py` |
| **Web** | `.html`, `.htm`, `.xml` |
| **TXTs** | `.txt`, `.md` |
| **Secrets** | `.env`, `.env.example` |

---

## Installation

Ensure you have Python 3.10+ installed.

1. **Clone or navigate to the directory**:
   ```bash
   cd directory-organizer
   ```

2. **Install dependencies**:
   ```bash
   pip3 install PySide6
   ```

---

## Usage

### Graphical Interface (GUI Mode)

Run the script without any parameters to launch the GUI:
```bash
python3 sortar.py
```

- Select either **Downloads** or **Documents** from the quick selection cards, or click **Browse...** to pick another path.
- Click **Organize Folder Now** to start.

### Command-line Mode (CLI Mode)

To integrate organizing in terminal scripts or cron tasks, specify the path as an argument:
```bash
python3 sortar.py /home/username/Downloads
```

> [!NOTE]
> In both GUI and CLI mode, the target folder's final directory name must be exactly `Downloads` or `Documents` (case-sensitive). If the name does not match, a validation warning will prevent organization.

---

## License
MIT License
