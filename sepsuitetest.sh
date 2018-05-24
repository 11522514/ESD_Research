#!/bin/sh -e

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 TestingVoltage_TestingPin"
  echo "Example: $0 n4kV_IO2_chip2_coreV1.4i_humid30"
  exit 1
fi

#mkdir -p data/updatedtests_v3/noreloadmem$1
#./sepprogramtest2_v3.sh testprograms/memtest.elf data/updatedtests_v3/noreloadmem$1/ 001 100

mkdir -p data/updatedtests_v3/noreloadall$1
./sepprogramtest2_v3.sh testprograms/alltest.elf data/updatedtests_v3/noreloadall$1/ 095 100

mkdir -p data/updatedtests_v3/noreloadalu$1
./sepprogramtest2_v3.sh testprograms/alutest.elf data/updatedtests_v3/noreloadalu$1/ 001 100

#mkdir -p data/updatedtests_v3/noreloadgpio$1
#./sepprogramtest2_v3.sh testprograms/gpiotest.elf data/updatedtests_v3/noreloadgpio$1/ 001 100

mkdir -p data/updatedtests_v3/reloadmem$1
./sepprogramtest_v3.sh testprograms/memtest.elf data/updatedtests_v3/reloadmem$1/ 001 100

mkdir -p data/updatedtests_v3/reloadall$1
./sepprogramtest_v3.sh testprograms/alltest.elf data/updatedtests_v3/reloadall$1/ 001 100

mkdir -p data/updatedtests_v3/reloadalu$1
./sepprogramtest_v3.sh testprograms/alutest.elf data/updatedtests_v3/reloadalu$1/ 001 100

#mkdir -p data/updatedtests_v3/reloadgpio$1
#./sepprogramtest_v3.sh testprograms/gpiotest.elf data/updatedtests_v3/reloadgpio$1/ 001 100
