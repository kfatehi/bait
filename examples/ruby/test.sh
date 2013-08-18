#!/bin/bash
bait_dir=$(dirname $0)
project_dir="$bait_dir/.."
cd $project_dir

echo "bundling"
bundle install > /dev/null 2>&1
bundle exec rspec spec
