import os
from uuid import uuid4 as UUID

path = "."


def run():
    """renames all files in directory and subdirectories"""
    for f in os.listdir(path):
        file = os.path.join(path, f)
        if os.path.isfile(file):
            new_name = f"renamed_{UUID()}{os.path.splitext(f)[1]}"
            os.rename(file, os.path.join(path, new_name))
        else:
            subpath = os.path.join(path, f)
            if os.path.isdir(subpath):
                os.chdir(subpath)
                run()
                os.chdir("..")


if __name__ == "__main__":
    run()
