require 'bait'
require 'bait/build'
require 'git'
require 'open3'
require 'celluloid'

module Bait
  class Tester
    def perform(build_id)
      puts "Actor was told to perform"
      if @build = ::Bait::Build.find(build_id)
        puts "Found build"
        @build.clone!
        @build.test!
      else
        puts "Build not found with id #{build_id}"
      end
    end
  end
end
