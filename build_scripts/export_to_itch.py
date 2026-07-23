
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
    subprocess.call(["butler", "push", target, "alexandrusurdu/the-curse-of-ct-downcula:html"])


def main():
    args_parser = argparse.ArgumentParser("export_to_itch")
    args_parser.add_argument("--export-target", default="Web")
    args_parser.add_argument("--destination", default=os.path.join(os.getcwd(), ".builds\\web\\the_curse_of_ct_downcula.zip"))
    args = args_parser.parse_args()
    os.makedirs(".build\\web", exist_ok=True)
    os.makedirs(os.path.dirname(args.destination), exist_ok=True)
    export(args.export_target)
    zip_target("E:\\programming\\godot\\good-enough\\.build\\web", args.destination)
    upload_to_itch(args.destination)


if __name__ == "__main__":
    main()

    