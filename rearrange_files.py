import shutil
from pathlib import Path
import os

def find_files_by_type(directory, file_extension):
    if isinstance(directory, str):
        directory = Path(directory)

    files = list(directory.rglob(f"*.{file_extension}"))
    return files

# Move regional files to regional directories
MOVE = [
    ("model/eurospores", "eurospores"),
    ("model/national", "national"),
]

# Copy non-regional files to regional directories
COPY_DIRS = [
    ("model/overrides-2030", "eurospores/overrides-2030"),
    ("eurospores/overrides-2030", "national/overrides-2030"),
]

# TODO: Get filespecific moves from dirs

FILES = [
    "config_overrides.yaml",
    "demand-techs.yaml",
    "heat-techs.yaml",
    "interest-rate.yaml",
    "legacy-techs.yaml",
    "link-techs.yaml",
    "renewable-techs.yaml",
    "spores.yaml",
    "storage-techs.yaml",
    "transformation-techs.yaml",
    "transport-techs.yaml",
]

COPY_FILES = [(f"model/{file}", f"eurospores/{file}") for file in FILES] + [(f"model/{file}", f"national/{file}") for file in FILES]

# TODO: Move timeseries to timeseries subfolder

print("\nMove directories:")
for dir in MOVE:
    print(f"{dir[0]} to {dir[1]}")

print("\nCopy directories:")
for dir in COPY_DIRS:
    print(f"{dir[0]} to {dir[1]}")

print("\nCopy files:")
for file in COPY_FILES:
    print(f"{file[0]} to {file[1]}")


def get_all_files(directory):
    found_files = []
    for root, dirs, files in os.walk(directory):
        for file in files:
            found_files.append(os.path.join(root, file))
    return found_files

# TODO: Move tech to tech subfolder
# TODO: Move overrides to overrides subfolder
# TODO: Keep links, locations, model at top level
# TODO: Rewrite relative paths in yaml files

def merge_directories(source, target):
    # Check if the target directory already exists
    if not os.path.exists(target):
        # If the target directory does not exist, simply move the source directory to it
        shutil.move(source, target)
    else:
        # If the target directory exists, merge the source directory with it
        for root, dirs, files in os.walk(source):
            relative_path = os.path.relpath(root, source)
            dest_path = os.path.join(target, relative_path)
            os.makedirs(dest_path, exist_ok=True)

            for file in files:
                src_file = os.path.join(root, file)
                dest_file = os.path.join(dest_path, file)
                shutil.move(src_file, dest_file)

def list_to_file(list_to_save, destination):
    with open(destination, "w") as f:
        for item in list_to_save:
            f.write(item + "\n")

if __name__ == "__main__":

    original = Path(snakemake.input[0]).absolute()
    rearranged = Path(snakemake.output[0]).absolute()

    files = get_all_files(Path(snakemake.input[0]))
    from_to_list = []

    from collections import namedtuple
    FromTo = namedtuple("FromTo", ["source", "destination", "destination_2"])

    for source in files:
        destination = ""
        destination_2 = ""
        source_path = Path(source)
        # move directories
        if "model/eurospores" in source:
            destination = source.replace("model/eurospores", "eurospores")
        elif "model/national" in source:
            destination = source.replace("model/national", "national")
        
        # copy directories
        elif "model/overrides-2030" in source:
            destination = source.replace("model/overrides-2030", "eurospores/overrides-2030")
            destination_2 = source.replace("model/overrides-2030", "national/overrides-2030")

        from_to_list.append(FromTo(source, destination, destination_2))
    
 


    list_to_file([item[0] for item in from_to_list], rearranged.parent / "from_list.txt")
    list_to_file([item[1] for item in from_to_list], rearranged.parent / "to_list.txt")
    list_to_file([item[2] if len(item)>2 else "" for item in from_to_list], rearranged.parent / "also_to_list.txt")


    shutil.copytree(original, rearranged)

    # for key, value in MOVE:
    #     print(f"Moving {rearranged / key} to {rearranged / value}")
    #     merge_directories(str(rearranged / key), str(rearranged / value))

    # for key, value in COPY_DIRS:
    #     print(f"Copying {rearranged / key} to {rearranged / value}")
    #     shutil.copytree(str(rearranged / key), str(rearranged / value))

    # for key, value in COPY_FILES:
    #     print(f"Copying {rearranged / key} to {rearranged / value}")
    #     shutil.copy(str(rearranged / key), str(rearranged / value))

    # shutil.rmtree(rearranged / "model")
