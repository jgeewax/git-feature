#!/bin/bash

# This assumes you're on a linux-like OS...
# These are more for me than anyone else...

test_dir=/tmp/test_feature_branch
rm -rf $test_dir
mkdir $test_dir
cd $test_dir
git init 1>/dev/null 2>&1
touch README
git add -A 1>/dev/null 2>&1
git commit -m "initial commit" 1>/dev/null 2>&1
curl --silent -L http://github.com/jgeewax/git-feature/raw/master/git-feature.sh | sh

echo "Y" | git feature my-feature 1>/dev/null 2>&1
first_branch_count=`git branch | wc -l`

echo "Y" | git abandon 1>/dev/null 2>&1
second_branch_count=`git branch | wc -l`

current_branch=`git branch | grep \* | cut -f2 -d" " -`
rm -rf $test_dir

echo -ne "Testing that we can create and abandon feature branches... "
if [ "$current_branch" == "master" -a "$first_branch_count" == "2" -a "$second_branch_count" == "1" ]
then
  echo "passed"
else
  echo "failed"
  exit 0
fi
