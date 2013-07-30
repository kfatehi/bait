Rmts
====

RubyMotion Test Service (aka Radical Metrical Test Sorcery)

# Inspiration

https://github.com/DFTi/Scribbeo-motion already is designed in such a way that it vendors our existing iOS (completely written in Objective-C) application https://github.com/DFTi/Critique

This gave us a Ruby(Motion) environment where UIAutomator is available using MacBacon (like rspec)

As a Ruby on Rails developer, this was invaluable... But the iOS developers we hired disliked it and did not maintain the RubyMotion stuff.

Fast forward a year or so later and the app is complex, has no test suite, and our QA testers can barely keep up.

Scribbeo-motion proved that this works, and so Rmts is a service I'm envisioning for as the first stop between Github and the rest of my continuous integration pipeline.

# Architectural Overview

```
                      Github POST rmts:80/
______________________        \./
|  Mac OS X 10.8     |         |
|   w/ RubyMotion    |         |
|  ----------------  +---------+----------------+
|                          +---+---+            |
|                          |Sinatra|            |
|                          +---+---+            |
|                              |                |
|                       +---------+--+          |
|                       |Rmts::Build |          |
|                       +---+-----+--+          |
|                           |     |             |
|                           |     |             |
|                          \|/   /|\            |
|                           |     |             |
|                           |     |             |
|                        +------------+         |
|   [.rmts/test.sh]------|Rmts::Tester|         |
|                        +------------+         |
|                                               |
+-----------------------------------------------+

   Rmts::Build -- Determine what kind of project it is.
                  Do a pre-flight check, and enqueue in Redis.

   Rmts::Tester -- Bootstrap and run test suite.
                   Read exit value and update record in Redis.
```

*Created with [JavE](http://www.jave.de/)*

# Functional Overview

## Github Webhook Support

Rmts provides a Sinatra endpoint for the github push event webhook.

When the repo is cloned, an Rmts executes a file relative to your
project. This file must exist in order to use Rmts: `.rmts/test.sh`

## .rmts/test.sh

In this file you will run your test suite. **Be sure to make it
executable `chmod a+x .rmts/test.sh`**

This file should output whatever you want to STDOUT/STDERR and return
the correct exit value.

### Example

```bash
#!/bin/bash
rmts_dir=$(dirname $0)
project_dir="$rmts_dir/.."
cd $project_dir
bundle
bundle exec rspec spec
```

## Objective-C ?

So you can see how Rmts will run any test suite via arbitrary bash
scripts upon a Github hook.

But how exactly will it help add a ruby test suite to an Obj-C app?

Watch this spot for some examples soon; essentially we'll be doing this
in Ruby using Rmts::Wrap::ObjC or some such :)

# Future

## Static Code Analysis

Integrate [metric-fu](http://metric-fu.rubyforge.org/) for ruby apps and [OCLint](http://oclint.org/) for objective-c apps. Report these in Redis.


