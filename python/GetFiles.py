import os
import time

def delete_old_files(directory, days=365):
    # Convert days to seconds
    cutoff = time.time() - (days * 86400)

    for root, dirs, files in os.walk(directory):
        for filename in files:
            file_path = os.path.join(root, filename)

            # Get file modification time
            file_mtime = os.path.getmtime(file_path)

            # Compare times
            if file_mtime < cutoff:
                try:
                    os.remove(file_path)
                    print(f"Deleted: {file_path}")
                except Exception as e:
                    print(f"Failed to delete {file_path}: {e}")

# Example usage:
delete_old_files("C:/path/to/your/folder", days=365)
