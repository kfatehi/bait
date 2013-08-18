#!/bin/bash
bait_dir=$(dirname $0)
project_dir="$bait_dir/.."
cd $project_dir

export BUNDLE_GEMFILE=./Gemfile

echo "bundling"
bundle install > /dev/null 2>&1

# The following will create screenshots and html report in report/
# It will also output to the console as usual for display in bait
SCREENSHOT_PATH=./report/ cucumber --format 'Calabash::Formatters::Html' \
  --out report/index.html \
  --format pretty --

# Objective-C projects are supported if you're using Calabash
# Available here: http://calaba.sh)
