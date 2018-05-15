#!/bin/sh -e
if [ ! -s tree.txt ]
then
    rm -f tree.txt
    echo "HI"
else
    echo "Nope"
fi
