rmts
====

RubyMotion Test Service (aka Radical Metrical Test Sorcery)

# Inspiration

https://github.com/DFTi/Scribbeo-motion already is designed in such a way that it vendors our existing iOS (completely written in Objective-C) application https://github.com/DFTi/Critique

This gave us a Ruby(Motion) environment where UIAutomator is available using MacBacon (like rspec)

As a Ruby on Rails developer, this was invaluable... But the iOS developers we hired disliked it and did not maintain the RubyMotion stuff.

Fast forward a year or so later and the app is complex, has no test suite, and our QA testers can barely keep up.

Scribbeo-motion proved that this works, and so RMTS is a service I'm envisioning for as the first stop between Github and the rest of my continuous integration pipeline.

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
|                    +---------+-------------+  |
|                    |RMTS::Build.new(params)|  |
|                    +------+-----+----------+  |
|                           |     |             |
|                           |     |             |
|                          \|/   /|\            |
|                           |     |             |
|                           |     |             |
|                          ++-----++            |
|         RMTS::Tester.new(| build |)           |
|                          +-------+            |
|                                               |
+-----------------------------------------------+

   RMTS::Build -- Determine what kind of project it is.
                  Do a pre-flight check, and enqueue in Redis.

   RMTS::Tester -- Bootstrap and run test suite.
                   Read exit value and update record in Redis.
```

*Created with [JavE](http://www.jave.de/)*

# Functional Overview

## Github Webhook Support

RMTS provides a Sinatra endpoint for the github push event webhook.

When the repo is cloned, an RMTS executes a file relative to your
project. This file must exist in order to use RMTS: `.rmts/test.sh`

## .rmts/test.sh

In this file you will run your test suite. **Be sure to make it
executable `chmod a+x .rmts/test.sh`**

This file should output whatever you want to STDOUT/STDERR and return
the correct exit value.

## Project Support

### Rails

Supported out of the box.

### RubyMotion

Supported out of the box.

### Objective-C

An Objective-C iOS project cloned is seen as a baby brother to RubyMotion. These apps need to grow up into full-fledged RubyMotion apps before RMTS can run use MacBacon to test it.

This growing up process occurs based on the files and folders beneath the definitions folder, `.rmts/`

## .rmts/

The folder `.rmts/` should be in your objective-c project and contain:
* `.rmts/Growfile`
* `.rmts/spec/` standard RubyMotion specs

### .rmts/Growfile

This is essential to making an Objective-C iOS application compatible with RMTS.

It must be an executable script that generates a valid rubymotion app at `.rmts/build/`

This can be written in any scripting language you prefer, but will likely be in bash.

It will be executed with Open3 in ruby by the RMTS::Grower. It must return a clean exit value to be passed on to an RMTS:::Tester

Output accumulated in this stage of the `RMTS::BuildProcess` will be saved to Redis

### .rmts/build/*

This should be added to your .gitignore and is where your rubymotion app will be built

### .rmts/spec/

This is a standard RubyMotion spec/ directory

# Future

## Static Code Analysis

Integrate [metric-fu](http://metric-fu.rubyforge.org/) for ruby apps and [OCLint](http://oclint.org/) for objective-c apps. Report these in Redis.

## 



