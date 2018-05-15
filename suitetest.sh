#!/bin/sh -e

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 TestingVoltage_TestingPin"
  echo "Example: $0 n4kV_IO2_chip2"
  exit 1
fi

mkdir -p data/updatedtests/noreloadmem$1
./programtest2.sh testprograms/memtest.elf data/updatedtests/noreloadmem$1/ 001
mkdir -p data/updatedtests/reloadmem$1
./programtest.sh testprograms/memtest.elf data/updatedtests/reloadmem$1/ 001
mkdir -p data/updatedtests/noreloadall$1
./programtest2.sh testprograms/alltest.elf data/updatedtests/noreloadall$1/ 001
mkdir -p data/updatedtests/noreloadalu$1
./programtest2.sh testprograms/alutest.elf data/updatedtests/noreloadalu$1/ 001
mkdir -p data/updatedtests/noreloadgpio$1
./programtest2.sh testprograms/gpiotest.elf data/updatedtests/noreloadgpio$1/ 001
mkdir -p data/updatedtests/reloadall$1
./programtest.sh testprograms/alltest.elf data/updatedtests/reloadall$1/ 001
mkdir -p data/updatedtests/reloadalu$1
./programtest.sh testprograms/alutest.elf data/updatedtests/reloadalu$1/ 001
mkdir -p data/updatedtests/reloadgpio$1
./programtest.sh testprograms/gpiotest.elf data/updatedtests/reloadgpio$1/ 001
