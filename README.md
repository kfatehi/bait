Bait
====

`bait` is a build and integration tester

# Backstory

https://github.com/DFTi/Scribbeo-motion already is designed in such a way that it vendors our existing iOS (completely written in Objective-C) application https://github.com/DFTi/Critique

This gave us a Ruby(Motion) environment where UIAutomator is available using MacBacon (like rspec)

As a Ruby on Rails developer, this was invaluable... But the iOS developers we hired disliked it and did not maintain the RubyMotion stuff.

Fast forward a year or so later and the app is complex, has no test suite, and our QA testers can barely keep up.

Scribbeo-motion proved that this works, and so bait is a service I'm envisioning for as the first stop between Github and the rest of my continuous integration pipeline.

# Architectural Overview

```
                      Github POST bait:80/
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

   Bait::Tester -- Runs your tests and updates build accordingly
```

*Created with [JavE](http://www.jave.de/)*

# Functional Overview

## Github Webhook Support

bait provides a Sinatra endpoint for the github push event webhook.

When the repo is cloned, an bait executes a file relative to your
project. This file must exist in order to use bait: `.bait/test.sh`

## .bait/test.sh

In this file you will run your test suite. **Be sure to make it
executable `chmod a+x .bait/test.sh`**

This file should output whatever you want to STDOUT/STDERR and return
the correct exit value.

### Examples

#### Ruby / Rails Example (RSpec)

##### [project root]/.bait/test.sh
```bash
#!/bin/bash
bait_dir=$(dirname $0)
project_dir="$bait_dir/.."
cd $project_dir


if [[ -f ./Gemfile ]]; then
  echo "Gemfile exists -- using bunder"
  bundle
  bundle exec rspec spec
else
  rspec spec
fi
```

#### RubyMotion Example

##### [project root]/.bait/test.sh
```bash
#!/bin/bash
bait_dir=$(dirname $0)
project_dir="$bait_dir/.."
cd $project_dir

if [[ -f ./Gemfile ]]; then
  echo "Gemfile exists -- bundling"
  bundle
fi

rake spec
```


## Objective-C ?

So you can see how bait will run any test suite via arbitrary bash
scripts upon a Github hook.

But how exactly will it help add a ruby test suite to an Obj-C app?

Watch this spot for some examples soon; essentially we'll be doing this
in Ruby using bait::Wrap::ObjC or some such :)

# Future

## Static Code Analysis

Integrate [metric-fu](http://metric-fu.rubyforge.org/) for ruby apps and [OCLint](http://oclint.org/) for objective-c apps. Report these in Redis.


