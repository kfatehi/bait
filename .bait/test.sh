#!/bin/bash
rmts_dir=$(dirname $0)
project_dir="$rmts_dir/.."
cd $project_dir

echo "bundling"
bundle > /dev/null 2>&1
bundle exec rspec spec
