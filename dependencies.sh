#!/bin/bash

#Project dependencies file
#Final authority on what's required to fully build the project

# byond version
# Extracted from the Dockerfile. Change by editing Dockerfile's FROM command.
LIST=($(sed -n 's/.*byond:\([0-9]\+\)\.\([0-9]\+\).*/\1 \2/p' Dockerfile))
export BYOND_MAJOR=${LIST[0]}
export BYOND_MINOR=${LIST[1]}
unset LIST

#rust_g git tag
export RUST_G_VERSION=0.4.7

#node version
export NODE_VERSION=12

# SpacemanDMM git tag
export SPACEMAN_DMM_VERSION=suite-1.6

# Extools git tag
<<<<<<< HEAD
export EXTOOLS_VERSION=v0.0.6
=======
export EXTOOLS_VERSION=v0.0.7

# Python version for mapmerge and other tools
export PYTHON_VERSION=3.6.8
>>>>>>> 34f0cc6... Upgrade extools version (#56104)
