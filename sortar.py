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

def validate_directory(target_dir):
    path = Path(target_dir).resolve()
    if not path.exists():
        return False, f"Error: directory '{target_dir}' does not exist."
    if not path.is_dir():
        return False, f"Error: '{target_dir}' is not a directory."
    if path.name not in ["Documents", "Downloads"]:
        return False, f"Error: Only 'Documents' or 'Downloads' (case sensitive) directories are supported."
    return True, ""

def organize_downloads(target_dir):
    valid, err = validate_directory(target_dir)
    if not valid:
        print(err)
        return False

    target_path = Path(target_dir).resolve()
    print(f"Organizing in '{target_path}'...\n")
    moved_count = 0

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
    return True

def run_gui():
    import sys
    try:
        from PySide6.QtGui import QGuiApplication
        from PySide6.QtQml import QQmlApplicationEngine
        from PySide6.QtCore import QObject, Signal, Slot, Property, QUrl
    except ImportError:
        print("Error: PySide6 is required to run the graphical interface.")
        print("Please install PySide6 using: pip install PySide6")
        sys.exit(1)
        
    class OrganizerBridge(QObject):
        targetDirectoryChanged = Signal(str)
        statusMessageChanged = Signal(str)
        isProcessingChanged = Signal(bool)
        logTextChanged = Signal(str)
        progressChanged = Signal(float)
        validationError = Signal(str)
        logsCleared = Signal()

        # Thread-safe helper signals
        _appendLogRequested = Signal(str)
        _progressRequested = Signal(float)
        _statusRequested = Signal(str)
        _processingRequested = Signal(bool)

        # Futuristic signals
        fileMoved = Signal(str, str)      # filename, folder_name
        playSoundRequested = Signal(str)  # sound name: scan, move, success, error

        def __init__(self):
            super().__init__()
            self._target_directory = ""
            self._status_message = "Select a directory to organize"
            self._is_processing = False
            self._log_text = ""
            self._progress = 0.0

            self._home_downloads = str(Path.home() / "Downloads")
            self._home_documents = str(Path.home() / "Documents")
            self._downloads_exists = (Path.home() / "Downloads").is_dir()
            self._documents_exists = (Path.home() / "Documents").is_dir()

            # Connect signals
            self._appendLogRequested.connect(self._handle_append_log)
            self._progressRequested.connect(self._handle_progress)
            self._statusRequested.connect(self._handle_status)
            self._processingRequested.connect(self._handle_processing)

        @Property(str, notify=targetDirectoryChanged)
        def targetDirectory(self):
            return self._target_directory

        @targetDirectory.setter
        def targetDirectory(self, val):
            if self._target_directory != val:
                self._target_directory = val
                self.targetDirectoryChanged.emit(val)

        @Property(str, notify=statusMessageChanged)
        def statusMessage(self):
            return self._status_message

        @statusMessage.setter
        def statusMessage(self, val):
            if self._status_message != val:
                self._status_message = val
                self.statusMessageChanged.emit(val)

        @Property(bool, notify=isProcessingChanged)
        def isProcessing(self):
            return self._is_processing

        @isProcessing.setter
        def isProcessing(self, val):
            if self._is_processing != val:
                self._is_processing = val
                self.isProcessingChanged.emit(val)

        @Property(str, notify=logTextChanged)
        def logText(self):
            return self._log_text

        @logText.setter
        def logText(self, val):
            if self._log_text != val:
                self._log_text = val
                self.logTextChanged.emit(val)

        @Property(float, notify=progressChanged)
        def progress(self):
            return self._progress

        @progress.setter
        def progress(self, val):
            if self._progress != val:
                self._progress = val
                self.progressChanged.emit(val)

        @Property(str, constant=True)
        def homeDownloads(self): return self._home_downloads
        @Property(str, constant=True)
        def homeDocuments(self): return self._home_documents
        @Property(bool, constant=True)
        def downloadsExists(self): return self._downloads_exists
        @Property(bool, constant=True)
        def documentsExists(self): return self._documents_exists

        def _handle_append_log(self, text): self.logText += text
        def _handle_progress(self, val): self.progress = val
        def _handle_status(self, text): self.statusMessage = text
        def _handle_processing(self, val): self.isProcessing = val

        @Slot(str)
        def playSound(self, sound_name: str):
            self.playSoundRequested.emit(sound_name)

        @Slot(str)
        def setTargetDirectoryFromUrl(self, url_str):
            url = QUrl(url_str)
            local_path = url.toLocalFile() if url.isLocalFile() else url_str
            if not local_path:
                local_path = url_str
            self.targetDirectory = os.path.abspath(local_path)

        @Slot()
        def startOrganizing(self):
            if self.isProcessing: return
            if not self.targetDirectory:
                self.validationError.emit("Please select or enter a directory path.")
                return

            valid, err = validate_directory(self.targetDirectory)
            if not valid:
                self.validationError.emit(err.replace("Error: ", ""))
                return

            self._processingRequested.emit(True)
            self._progressRequested.emit(0.0)
            self._statusRequested.emit("Scanning directory...")
            self.logText = ""
            self.logsCleared.emit()
            self.playSound("scan")

            import threading
            thread = threading.Thread(target=self._organize_worker, args=(self.targetDirectory,))
            thread.daemon = True
            thread.start()

        def _organize_worker(self, target_dir):
            target_path = Path(target_dir).resolve()
            self._appendLogRequested.emit(f"Scanning target directory '{target_path}'...\n")
            
            try:
                items = [item for item in target_path.iterdir() if item.is_file() and not item.name.startswith('.')]
                total_items = len(items)

                if total_items == 0:
                    self._appendLogRequested.emit("No files found to organize.\n")
                    self._progressRequested.emit(1.0)
                    self._statusRequested.emit("Finished. No files to sort.")
                    self._processingRequested.emit(False)
                    return

                self._statusRequested.emit(f"Organizing {total_items} files...")
                moved_count = 0
                
                for idx, item in enumerate(items):
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
                            self._appendLogRequested.emit(f"Moved: {item.name} ➔ {folder_name}/\n")
                            self.fileMoved.emit(item.name, folder_name)
                            self.playSound("move")
                            moved_count += 1
                        except PermissionError:
                            self._appendLogRequested.emit(f"Skipped (Permission Denied): {item.name}\n")
                            self.playSound("error")
                        except Exception as e:
                            self._appendLogRequested.emit(f"Error moving {item.name}: {e}\n")
                            self.playSound("error")
                    
                    self._progressRequested.emit((idx + 1) / total_items)
                
                self._appendLogRequested.emit(f"\n--- Finished! Successfully organized {moved_count} file(s).")
                self._statusRequested.emit(f"Finished organizing {target_path.name}!")
                self.playSound("success")
            except Exception as e:
                self._statusRequested.emit("Error during organization.")
                self._appendLogRequested.emit(f"Critical Error: {e}\n")
                self.playSound("error")
            finally:
                self._processingRequested.emit(False)

    app = QGuiApplication(sys.argv)
    bridge = OrganizerBridge()
    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("dirBridge", bridge)
    
    qml_file = Path(__file__).resolve().parent / "main.qml"
    engine.load(str(qml_file))
    
    if not engine.rootObjects():
        sys.exit(-1)
        
    sys.exit(app.exec())

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Organize Files by Extension.")
    parser.add_argument("directory", nargs="?", help="Directory to organize. If omitted, launches the GUI.")
    args = parser.parse_args()
    
    if args.directory:
        organize_downloads(args.directory)
    else:
        run_gui()
