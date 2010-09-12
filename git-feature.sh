#!/bin/sh

git config alias.feature '!sh -c "
current=\`git branch | grep ^\\* | cut -f2 -d\" \" - | tail -c +10\`
if [ \"\$1\" -a \"\$1\" = \"--current\" ]
then
 if [ \$current ]
 then
  echo \$current
 fi
 exit 0
fi

if [ \$1 ]
then
 feature=\$1
else
 read -p \"feature name: \" feature
fi

if [ -z \$feature ]
then
 exit 0
elif [ \`git branch | grep features/\$feature\\\$\` ]
then
 git checkout features/\$feature
 exit 0
fi

if [ \$2 ]
then
 parent=\$2
elif [ \$current ]
then
 read -p \"where will this feature be merged into when it is done? \" parent
else
 parent=\`git branch | grep ^\\* | cut -f2 -d\" \" -\`
fi

if [ -z \$parent ]
then
 exit 0
fi

read -p \"this will create a feature branch \$feature to be merged into \$parent (Y/n): \" YN
if [ -z \"\$YN\" -o \"\$YN\" = \"y\" -o \"\$YN\" = \"Y\" ]
then
 git config \$feature.parent \$parent
 git checkout \$parent
 git checkout -b features/\$feature
else
 echo \"aborting...\"
 exit 0
fi
" -'

git config alias.integrate '!sh -c "
current=\`git branch | grep ^\\* | cut -f2 -d\" \" -\`
if [ -n \"\$1\" -a -n \"\$2\" -a -z \"\$3\" ]
then
 feature=\$1
 parent=\$2
elif [ -n \"\$1\" -a -z \"\$2\" ]
then
 if [ -n \"\`git feature --current\`\" ]
 then
  parent=\$1
  feature=\`git feature --current\`
 else
  parent=\$current
  feature=\$1
 fi
elif [ -z \"\$1\" -a -n \"\`git feature --current\`\" ]
then
 feature=\`git feature --current\`
 parent=\`git config \$feature.parent\`
fi

if [ -z \"\$feature\" ]
then
 read -p \"what feature are we integrating? \" feature
fi
if [ -z \"\$parent\" ]
then
 read -p \"where should this feature be integrated into? \" parent
fi

if [ -z \"\$parent\" -o -z \"\$feature\" ]
then
 exit 0
fi

read -p \"this will integrate \$feature into \$parent (Y/n): \" YN
if [ -z \"\$YN\" -o \"\$YN\" = \"y\" -o \"\$YN\" = \"Y\" ]
then
 git checkout features/\$feature
 git rebase -i \$parent
 git checkout \$parent
 git merge features/\$feature
 git checkout \$current
else
 echo \"aborting...\"
fi
exit 0
" -'

git config alias.finish '!sh -c "
feature=\`git feature --current\`
parent=\`git config \$feature.parent\`
if [ -z \"\$feature\" ]
then
 echo \"you must be on a feature branch to use this\"
 exit 1
fi

git integrate
git checkout \$parent
git branch -d features/\$feature
git config --remove-section \$feature
" -'

git config alias.checkpoint '!sh -c "
feature=\`git feature --current\`
if [ -z \"\$feature\" ]
then
  echo \"you must be on a feature branch to use this\"
  exit 1
fi

git add -A
git commit -m \"Checkpoint for features/\$feature\"
" -'
