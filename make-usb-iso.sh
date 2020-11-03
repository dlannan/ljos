#!/bin/bash

echo "Writing bb.iso to device: $1"
read -p "Are you sure (y/n)? " answer
case ${answer:0:1} in
    y|Y )
        sudo dd if=$2/bb.iso of=$1 status="progress"
    ;;
    * )
        echo "Writing cancelled."
    ;;
esac
