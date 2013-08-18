Bait
====

executable is `bait`, standing for Build And Integration Tester
I'm conflicted about the name, another is artci: Application-Readiness-Test-based Continuous Integration

The most important thing to know about this project is this:

You are the only one that knows how your software "integrates" and the
truth is that this is about people and process as much as about code.

If some of your developers test, and some don't, those that don't are 
kind of a liability so the best way to push them to grow is to give them
the benefit of all these tools in the awesome open source culture

As you write scripts that make this program useful in different
contexts please contribute them to the Wiki.

After you gem install, you setup your projects this way:

Step 1. cd into your project
Step 2. bait init
Step 3. bait test

Commit the new directory and scripts and you will be able to use the project with bait.

See examples/ for scripts for various types of projects.

# Usage

Install the gem and then run `bait`

A sinatra server will start up. YAML files and temp repos will be stored in ~/.bait

Go to 0.0.0.0:8417

You can set your Github to notify the server on that port.

You may also test manually by inputting a clone URL within the UI

# Architectural Overview

```
           Github POST bait:8417/--------+
                                         |
+----------------------------------------|------+
|    +------------+                  +--\|/--+  | +-------------+
|    | new Build  <------------------|  API  <------  GET /     |
|    +-----+------+                  |       |  | |             |
|          |                         |       |  | |             |
|          |                         |/build------> Build.all() |
|          |        +-------------+  |       |  | |             |
|     +---\|/----+  |Subscription <------+   |  | |             |
|     |Queue Job |  |  to Build   |  |   |   |  | | UI Changes  |
|     +----+-----+  |   Event     |  |   |   |  | |     |       |
|          |        | Broadcasts  |  |   |   |  | |     |       |
|          |        +--+------+---+  |/events----->[EventSource]|
|    +----\|/-----+    |      |      +---+---+  | +-------------+
|    |  Workers   |    |      |          |      |
|    |[subprocess]+----+      +----------+      |
|    +------------+                             |
|                                               |
+-----------------------------------------------+
```

*Created with [JavE](http://www.jave.de/)*

# Datastore

You can use any datastore you want that is supported in [Moneta](https://github.com/minad/moneta)

By default, bait will store the data as YAML files in `~/.bait`

# Features

## List-Of-Scripts Configuration

After you `bait init` you will see how this works

## Github Webhook Support

bait provides a Sinatra endpoint for the github push event webhook.

It will clone and run the list of scripts automatically

## SimpleCov Support

If your test suite builds the path `coverage/index.html` such as SimpleCov does
then bait will detect it and provide access to it from a link in the UI.

This feature was introduced in bait v0.5.4

Please send pull requests with script examples if you use bait.
