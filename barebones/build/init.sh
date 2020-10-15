#!/bin/sh

mount -t proc proc /proc
mount -t sysfs sysfs /sys

mdev -s

while true
do
	setsid cttyhack sh
	sleep 1
done