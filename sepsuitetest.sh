#!/bin/sh -e

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 TestingVoltage_TestingPin"
  echo "Example: $0 n4kV_IO2_chip2"
  exit 1
fi

#mkdir -p data/updatedtests_v2/noreloadmem$1
#./sepprogramtest2_v2.sh testprograms/memtest.elf data/updatedtests_v2/noreloadmem$1/ 001
mkdir -p data/updatedtests_v2/noreloadall$1
./sepprogramtest2_v2.sh testprograms/alltest.elf data/updatedtests_v2/noreloadall$1/ 001
#mkdir -p data/updatedtests_v2/noreloadalu$1
#./sepprogramtest2_v2.sh testprograms/alutest.elf data/updatedtests_v2/noreloadalu$1/ 140

#mkdir -p data/updatedtests_v2/noreloadgpio$1
#./sepprogramtest2_v2.sh testprograms/gpiotest.elf data/updatedtests_v2/noreloadgpio$1/ 001

#mkdir -p data/updatedtests_v2/reloadmem$1
#./sepprogramtest_v2.sh testprograms/memtest.elf data/updatedtests_v2/reloadmem$1/ 001
mkdir -p data/updatedtests_v2/reloadall$1
./sepprogramtest_v2.sh testprograms/alltest.elf data/updatedtests_v2/reloadall$1/ 001
#mkdir -p data/updatedtests_v2/reloadalu$1
#./sepprogramtest_v2.sh testprograms/alutest.elf data/updatedtests_v2/reloadalu$1/ 001

#mkdir -p data/updatedtests_v2/reloadgpio$1
#./sepprogramtest_v2.sh testprograms/gpiotest.elf data/updatedtests_v2/reloadgpio$1/ 001
