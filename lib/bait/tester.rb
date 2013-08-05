require 'bait'
require 'bait/build'
require 'git'
require 'open3'
require 'sucker_punch'

module Bait
  class Tester
    include SuckerPunch::Job
    def perform(build_id)
      if @build = ::Bait::Build.find(build_id)
        @build.clone!
        @build.test!
        # @build.analyze!
      end
    end
  end
end
