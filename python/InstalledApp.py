import os
import win32api

def get_file_version(file_path):
    try:
        info = win32api.GetFileVersionInfo(file_path, "\\")
        ms = info['FileVersionMS']
        ls = info['FileVersionLS']
        return f"{win32api.HIWORD(ms)}.{win32api.LOWORD(ms)}.{win32api.HIWORD(ls)}.{win32api.LOWORD(ls)}"
    except Exception as e:
        return None

if __name__ == "__main__":
    # Default installation path — adjust if needed
    default_path = r"C:\Program Files\Notepad++\notepad++.exe"
    if not os.path.exists(default_path):
        default_path = r"C:\Program Files (x86)\Notepad++\notepad++.exe"

    version = get_file_version(default_path)
    if version:
        print(f"✅ Notepad++ version (from EXE): {version}")
    else:
        print(f"❌ Notepad++ executable not found.")
