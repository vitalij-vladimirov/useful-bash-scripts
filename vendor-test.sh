#!/bin/bash

# LOCAL VENDOR TESTING KNOW HOW
#
# To test library locally it needs to be installed (composer require) and then mocked from local location as a symlink.
# This script helps to create symlink running less commands.
#   1. Run `composer install` if library is not installed yet.
#   2. Run `./vendor-test.sh library-name` to mock library (specify your library instead of `library-name`).
#      Originally installed library will be replaced with local mock.
# To rollback original library version remove symlink manually and run `composer install`.
#
# Your must include volume specified in LIBS_DIR and run it in the same directory inside of the image.
# In any other cases symlink will not work inside of docker image.
# docker-compose.override.yml example:
# > version: "3"
# >  services:
# >    php:
# >      volumes:
# >        - /home/user/projects/libs:/home/user/projects/libs

LIBS_DIR=~/projects/libs/ # Specify path to local location of library
VENDOR_DIR="opay-dev"     # Specify vendor name where testing libraries must be stored

if [ -z "$1" ]; then
  echo -e "\033[31mSpecify library name.\033[0m";
  exit
fi

FULL_VENDOR_PATH="${PWD}/vendor/${VENDOR_DIR}"
if [ ! -d "$FULL_VENDOR_PATH" ]; then
  echo -e "\033[31mVendor directory \"$FULL_VENDOR_PATH\" not found.\033[0m"
  echo "Run \`composer install\` before vendor testing."
  exit
fi

TEST_LIB_DIR="${LIBS_DIR}${1}"
if [ ! -d "$TEST_LIB_DIR" ]; then
  echo -e "\033[31mSpecified library \"${1}\" not found in ${LIBS_DIR}\033[0m"
  exit
fi

TEST_LIB_VENDOR_DIR="${FULL_VENDOR_PATH}/${1}"
if [ -d "$TEST_LIB_VENDOR_DIR" ]; then
  rm -rf "$TEST_LIB_VENDOR_DIR"
fi

ln -s "$TEST_LIB_DIR" "$TEST_LIB_VENDOR_DIR"

echo -e "\033[32mLibrary testing symlink created!\033[0m"
echo "Symlink path: $TEST_LIB_VENDOR_DIR"
