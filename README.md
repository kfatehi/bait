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

