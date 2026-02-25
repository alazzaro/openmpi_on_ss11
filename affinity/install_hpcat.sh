#!/bin/bash

git clone --recurse-submodules https://github.com/HewlettPackard/hpcat.git
cd hpcat
source ../../sourceme_ompi.sh
./configure
make install
