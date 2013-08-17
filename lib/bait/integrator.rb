require 'bait'
require 'bait/build'
require 'git'
require 'open3'
require 'sucker_punch'

module Bait
  class Integrator
    include SuckerPunch::Job
    def perform(build_id)
      if @build = ::Bait::Build.find(build_id)
        @build.clone!
        if @build.cloned?
          @build.phases.each do |script|
            @build.enter_phase script
          end
        end
      end
    end
  end
end
