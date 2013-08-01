Bait
====

`bait` is a build and integration tester

# Usage

Install the gem and then just run `bait`

A sinatra server will start up. YAML files will be stored in ~/.bait

Hit up 0.0.0.0:8417 to see what's up. You can set your Github to notify it and it will run your tests per the bait spec.

# Backstory

https://github.com/DFTi/Scribbeo-motion already is designed in such a way that it vendors our existing iOS (completely written in Objective-C) application https://github.com/DFTi/Critique

This gave us a Ruby(Motion) environment where UIAutomator is available using MacBacon (like rspec)

As a Ruby on Rails developer, this was invaluable... But the iOS developers we hired disliked it and did not maintain the RubyMotion stuff.

Fast forward a year or so later and the app is complex, has no test suite, and our QA testers can barely keep up.

Scribbeo-motion proved that this works, and so bait is a service I'm envisioning for as the first stop between Github and the rest of my continuous integration pipeline.

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
|                          \|/   /|\            |
|                        +------------+         |
|   [.bait/test.sh]------|Bait::Tester|         |
|                        +------------+         |
|                                               |
+-----------------------------------------------+

   Bait::Build -- Persistent ToyStore

   Bait::Tester -- Runs your tests and persists results in Bait::Build
```

*Created with [JavE](http://www.jave.de/)*

# Datastore

You can use any datastore you want that is supported in [Moneta](https://github.com/minad/moneta)

By default, bait will store its data under `~/.bait` as YAML files

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
