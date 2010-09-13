#!/bin/bash

chmod a+x *.sh

./test_feature_create.sh
./test_feature_create_and_abandon.sh
./test_abandon_from_different_branch.sh