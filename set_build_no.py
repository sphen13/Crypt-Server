#!/usr/bin/env python3

import os
import plistlib
import subprocess

current_version = "3.4.1"
script_path = os.path.dirname(os.path.realpath(__file__))


# based on http://tgoode.com/2014/06/05/sensible-way-increment-bundle-version-cfbundleversion-xcode

print("Setting Version to Git rev-list --count")
cmd = ["git", "rev-list", "HEAD", "--count"]
build_number = subprocess.check_output(cmd)
# This will always be one commit behind, so this makes it current
build_number = int(build_number) + 1

version_number = "{}.{}".format(current_version, build_number)

data = {"version": version_number}
plist_path = "{}/fvserver/version.plist".format(script_path)
file_name = open(plist_path, "wb")
plistlib.dump(data, file_name)
file_name.close()
