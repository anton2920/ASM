#!/bin/bash

#FDRIVE=$(lsblk -f | grep 171C-361A | cut -d ' ' -f 1)
FDRIVE="sde"

if [[ x$FDRIVE != x"" ]] ; then
	sudo dd if=./boot.bin of=/dev/$FDRIVE
else
	echo "Please connect the floppy drive!"
fi
