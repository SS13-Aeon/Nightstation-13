#!/bin/bash

#Project dependencies file
#Final authority on what's required to fully build the project

# byond version
<<<<<<< HEAD
# Extracted from the Dockerfile. Change by editing Dockerfile's FROM command.
LIST=($(sed -n 's/.*byond:\([0-9]\+\)\.\([0-9]\+\).*/\1 \2/p' Dockerfile))
export BYOND_MAJOR=${LIST[0]}
export BYOND_MINOR=${LIST[1]}
unset LIST
=======
export BYOND_MAJOR=513
export BYOND_MINOR=1533
>>>>>>> c9aa81d... Update Dockerfile for CBT (#56175)

#rust_g git tag
export RUST_G_VERSION=0.4.7

#node version
export NODE_VERSION=12

# SpacemanDMM git tag
export SPACEMAN_DMM_VERSION=suite-1.6

# Extools git tag
export EXTOOLS_VERSION=v0.0.6
