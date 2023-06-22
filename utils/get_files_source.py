import os

exclude_files = [
    "init_dirs.tcl",
    "test.tcl",
]

def list_tcl_files_recursive(path):
    files = []
    for r, d, f in os.walk(path):
        for file in f:
            if file.endswith('.tcl') and not any(map(lambda x: file.endswith(x), exclude_files)) and not file.endswith("main.tcl"):
                files.append(os.path.join(r, file))
    return map(lambda f: f.replace("\\", "/"), files)

if __name__ == '__main__':
    with open('init_dirs.tcl', 'w') as f:
        for file in list_tcl_files_recursive('.'):
            f.write(f"source \"{file}\"\n")