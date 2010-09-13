#!/bin/bash

# This assumes you're on a linux-like OS...
# These are more for me than anyone else...

test_dir=/tmp/test_feature_branch
rm -rf $test_dir
mkdir $test_dir
cd $test_dir
git init 1>/dev/null
touch README
git add -A 1>/dev/null
git commit -m "initial commit" 1>/dev/null
curl --silent -L http://github.com/jgeewax/git-feature/raw/master/git-feature.sh | sh

echo "Y" | git feature foo 2>/dev/null
current_feature=`git feature --current`
current_branch=`git branch | grep \* | cut -f2 -d" " -`
rm -rf $test_dir

echo -ne "Testing that we can create feature branches... "
if [ "$current_feature" != "foo" -a "$current_branch" == "features/foo" ]
then
  echo "failed"
  exit 1
else
  echo "passed"
fi
