Bait
====

`bait` is a build and integration tester

# Usage

Install the gem and then just run `bait`

A sinatra server will start up. YAML files will be stored in ~/.bait

Go to 0.0.0.0:8417

You can set your Github to notify the server on that port.

When github notifies bait, bait will clone the project and execute ~/.bait/test.sh and record exit value and output

You may also test manually by inputting a clone URL within the UI

# Architectural Overview

```
                    Github POST bait:8417/
______________________        \./
|  Mac OS X 10.8     |         |
|   w/ RubyMotion    |         |
|  ----------------  +---------+----------------+
|                          +---+---+            |
|                          |  API  |----[haml]------- you
|                          +---+---+            |
|                              |                |
|                       +---------+--+          |
|                       |Bait::Build |          |
|                       +---+-----+--+          |
|                          \|/   /|\            |
|                          \|/   /|\            |
|                          \[build]\            |
|                          \|/   /|\            |
|    _____________         \|/   /|\            |
|   [ your project]      +------------+         |
|   [.bait/test.sh]------|Bait::Tester|         |
|   [status/output]      +------------+         |
|                                               |
+-----------------------------------------------+

   Bait::Build -- Persistent ToyStore

   Bait::Tester -- Runs your tests and persists results in Bait::Build
```

*Created with [JavE](http://www.jave.de/)*

# Datastore

You can use any datastore you want that is supported in [Moneta](https://github.com/minad/moneta)

By default, bait will store the data as YAML files in `~/bait`

# Functional Overview

## Github Webhook Support

bait provides a Sinatra endpoint for the github push event webhook.

When the repo is cloned, an bait executes a file relative to your
project. This file must exist in order to use bait: `.bait/test.sh`

## .bait/test.sh

In this file you will run your test suite. **Be sure to make it
executable `chmod a+x .bait/test.sh`**

This file should output whatever you want to STDOUT and/or STDERR and
return 0 for passing and non-zero for failure.

### Examples

#### Ruby Projects

##### [project root]/.bait/test.sh
```bash
#!/bin/bash
bait_dir=$(dirname $0)
project_dir="$bait_dir/.."
cd $project_dir

echo "bundling"
bundle install > /dev/null 2>&1
bundle exec rspec spec
```

#### RubyMotion Projects

##### [project root]/.bait/test.sh
```bash
#!/bin/bash
bait_dir=$(dirname $0)
project_dir="$bait_dir/.."
cd $project_dir

export BUNDLE_GEMFILE=$project_dir/Gemfile

echo "bundling"
bundle install > /dev/null 2>&1
bundle exec motion-specwrap
```

An example project that will work on bait can be [found
here](https://github.com/keyvanfatehi/baitmotion)

There is a bug in RubyMotion where the exit value isn't reported
properly, that's why we are using
[motion-specwrap](https://github.com/mdks/motion-specwrap) to run the
tests and report the correct exit value

#### Objective-C Projects

Objective-C projects are supported if you're using [Calabash](http://calaba.sh)

##### [project root]/.bait/test.sh
```
#!/bin/bash
bait_dir=$(dirname $0)
project_dir="$bait_dir/.."
cd $project_dir

export BUNDLE_GEMFILE=$project_dir/Gemfile

echo "bundling"
bundle install > /dev/null 2>&1
bundle exec cucumber
```

#### Other Projects

Create a file `.bait/test.sh` and `exit 0` if it passes or non-zero if
it does not pass. Output whatever you want to STDOUT or STDERR.

Feel free to send pull requests with examples if you end up using bait.

# Future Goals

## Static Code Analysis

Integrate [metric-fu](http://metric-fu.rubyforge.org/) for ruby apps and [OCLint](http://oclint.org/) for objective-c apps, JSLint and JSure for javascript.
