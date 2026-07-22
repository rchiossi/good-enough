
import argparse
import subprocess
import os

def export(target):
    print("Export godot export")
    subprocess.call(["godot", "--export-release", target])

def zip_target(folder, destination):
    cwd = os.getcwd()
    os.chdir(folder)
    print("Zipping")
    subprocess.call(["tar.exe", "-a", "-c", "-f", destination, "*"])
    os.chdir(cwd)

def upload_to_itch(target):
    print("Uploading")
    subprocess.call(["butler", "push", target, target_link])


def main():
    args_parser = argparse.ArgumentParser("export_to_itch")
    args_parser.add_argument("--export-target", default="Web")
    args_parser.add_argument("--destination", default=os.path.join(os.getcwd(), "build\\web\\good_enough.zip"))
    args = args_parser.parse_args()
    export(args.export_target)
    zip_target(location_disk, args.destination)
    upload_to_itch(args.destination)


if __name__ == "__main__":
    main()

