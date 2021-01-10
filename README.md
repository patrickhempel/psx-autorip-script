# MakeMKV-AutoRip-Script
A bash script for automatically ripping movies and TV shows using [MakeMKV](https://www.makemkv.com/).
It has been written with the focus on parallelization, so that you can rip from multiple drives at once.

Disks will automatically be ejected once they're finished and newly inserted disks will automatically be ripped with the predefined, global parameters in the settings.cfg file.

# Disclaimer
This script has only been tested on Ubuntu 20.04.01. Whilst it might work with other systems, I can't guarantee for it.

# Installation:
Install MakeMKV: [Linux Installation Docs](https://www.makemkv.com/forum/viewtopic.php?t=224)

The packages mentioned in their docs don't seem to be totally up to date, I recommend this bundle:
`apt-get install build-essential pkg-config libc6-dev libssl-dev libexpat1-dev libavcodec-dev libgl1-mesa-dev qtbase5-dev zlib1g-dev nasm libfdk-aac-dev sed wget curl tar setcd`

This set features the libavcodec, so keep you'd be best of installing MakeMKV with support for it (see "OPTIONAL: Building with latest libavcodec" and "with libfdk-aac support" in their [docs](https://www.makemkv.com/forum/viewtopic.php?t=224)).

It also includes some **necessary packages** for this script to run: `sed grep setcd`.
Make sure these are present on your system before running the script.

Start MakeMKVCon at least once before using this script: `/usr/bin/makemkvcon`.
This will make sure the necessary config files are being created properly and that the installation has succeeded.

Download the scripts and setting file to a directory of your choice and make the scripts executable. Then, just run the wrapper and you're good to go: `bash wrapper.sh`

Happy ripping!
