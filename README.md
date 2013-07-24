rmts
====

RubyMotion Test Service (aka Radical Metrical Test Sorcery)

## Architecture Overview

```
Github POST rmts:80/gh_user/gh_project
      |
  +---+---+                +-----------------------+
  |Sinatra|--------------->|RMTS::Build.new(params)|
  +-------+                +---------------+-------+
                                           |
                                           |
 +--------------------+                    |
 |  Mac OS X 10.8     |    +---------------|------------+
 |   w/ RubyMotion    |    |Redis Queue    |            |
 |  ----------------  |    |   +-----------#-----------+|
 |  RMTS::Worker      |    |   |build:{github_info:...,||
 | (a Sidekiq Worker) |    |   |       other_info:...} ||
 |                    |    |   +-----------#-----------+|
 |                    |    |               |            |
 |                    |    +---------------|------------+
 |                    `--------------------|-----+
 |                          +-------+      |     |
 |         RMTS::Tester.new(| build |)-----`     |
 |                          +-------+            |
 |                                               |
 +-----------------------------------------------+

   RMTS::Build -- Determine what kind of project it is.
                  Do a pre-flight check, and enqueue in Redis.

   RMTS::Tester -- Bootstrap and run test suite.
                   Read exit value and update record in Redis.
```

*Created with [JavE](http://www.jave.de/)*

## Inspiration

https://github.com/DFTi/Scribbeo-motion already is designed in such a way that it vendors our existing iOS (completely written in Objective-C) application https://github.com/DFTi/Critique

This gave us a Ruby(Motion) environment where UIAutomator is available using MacBacon (like rspec)

As a Ruby on Rails developer, this was invaluable... But the iOS developers we hired disliked it and did not maintain the RubyMotion stuff.

Fast forward a year or so later and the app is complex, has no test suite, and our poor QA testers cannot keep up.

Scribbeo-motion proved that this works, and so RMTS is a service I'm envisioning for as the first stop between Github and the rest of my continuous integration pipeline.

## Github integration

RMTS provides a Sinatra endpoint for the github push event webhook.

## Tooling Support

### Rails

Rails will be supported by RMTS

### RubyMotion

Rubymotion is a first class citizen. 

This means RMTS can execute its test suite and update Redis about that run.

The only configuration necessary is to create a .rmts file or folder in the repository.

### Objective-C

Objective-C is the baby brother of RubyMotion. These apps need to grow up into RubyMotion apps before RMTS can run a RubyMotion-style test suite.

This growing up process occurs based on the files and folders beneath the definitions folder, `.rmts/`

## Definitions

The folder `.rmts/` should be in your project root. An objective-c project is expected to contain:
* `.rmts/Grow` is an executable script that deploys a rubymotion app into `.rmts/build/`
* 
*
* `.rmts/spec/` standard RubyMotion specs go here

### Grow file

This can be written in any scripting language langauge you want and will be executed with Open3 in Ruby within the context of an 

which is created and should be added to gitignore

### 
* standard RubyMotion specs/ directory


### 

## Static Code Analysis

http://metric-fu.rubyforge.org/

http://oclint.org/