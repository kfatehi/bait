#!/bin/bash
rmts_dir=$(dirname $0)
project_dir="$rmts_dir/.."

cd $project_dir
bundle
bundle exec rspec spec
