rmts
====

RubyMotion Test Service (aka Rubyriffic Magical Testing System)

## Architecture Overview

```
Github POST rmts:80/gh_user/gh_project
      |
  +---+---+                +-----------------------+
  |Sinatra|--------------->|RTMS::Build.new(params)|
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

Scribbeo-motion proved that this works, and so RTMS is a continuous integration service where RubyMotion is first-class.

RMTS is the CI server (running on a mac), it is an endpoint for the github push event webhook
On request from github, RMTS pulls the obj-c project, wraps it as a rubymotion app, and runs the specs (written in Ruby)
