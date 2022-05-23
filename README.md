# PSX-AutoRip-Script

# Fork of [ThisIsTenou/makemkv-autorip-script](https://github.com/ThisIsTenou/makemkv-autorip-script)

A bash script for automatically ripping PlayStation games into chd format using [cdrdao](http://cdrdao.sourceforge.net/), [chdman](https://wiki.recalbox.com/en/tutorials/utilities/rom-conversion/chdman).
It has been written with the focus on parallelization, so that you can rip from multiple drives at once.

Disks will automatically be ejected once they're finished and newly inserted disks will automatically be ripped with the predefined, global parameters in the settings.cfg file.

# Disclaimer
This script has only been tested on Ubuntu 20.04.01. Whilst it might work with other systems, I can't guarantee for it.

# Installation:
Install cdrdao and chdman

`apt install cdrdao mame-tools`

It also includes some **necessary packages** for this script to run: `sed grep setcd`.
Make sure these are present on your system before running the script.
Then, just run the wrapper and you're good to go: `bash wrapper.sh`

Happy ripping!

# Note
If you just want to rip a single disc with your predefined settings, you can call the autorip.sh-script directly, by passing the drive's location as an argument: `bash autorip.sh /dev/sr0`.
This will rip the disc the same way as with the wrapper, but just once, without all the sweet automation.
