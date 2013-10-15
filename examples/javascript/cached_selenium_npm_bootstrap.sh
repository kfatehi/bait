#!/bin/bash
bait_dir=$(dirname $0)
cd $bait_dir/..
project_dir=`pwd`

if [[ ! `pwd` =~ $HOME/.bait/production ]]; then
  cd $project_dir
  npm install
  if [[ ! -d selenium ]]; then
    npm run-script selenium-installer
  fi
else
  cd ../..
  shared_dir=`pwd`
  cd $project_dir
  cat package.json > $shared_dir/package.json
  cd $shared_dir
  npm install
  if [[ ! -d selenium ]]; then
    npm run-script selenium-installer
  fi
  ln -s $shared_dir/node_modules $project_dir/node_modules
  ln -s $shared_dir/selenium $project_dir/selenium
fi


