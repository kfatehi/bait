require 'rmts'
require 'rmts/build'
require 'fileutils'

module Rmts
  class BuildTester
    def initialize build
      @build = build
    end

    def sandbox_directory
      @sandbox_directory ||= begin
        dir = File.join Rmts.storage_dir, "build_tester", @build.id
        FileUtils.mkdir_p dir
        dir
      end
    end
  end
end
