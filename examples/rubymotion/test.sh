#!/bin/bash
bait_dir=$(dirname $0)
project_dir="$bait_dir/.."
cd $project_dir

export BUNDLE_GEMFILE=$project_dir/Gemfile

echo "bundling"
bundle install > /dev/null 2>&1
bundle exec motion-specwrap

# An example project that uses this can be found 
# here: https://github.com/keyvanfatehi/baitmotion

# There's a bug in RubyMotion where the exit value isn't reported
# properly, that's why we are using motion-specwrap found
# here: https://github.com/mdks/motion-specwrap
