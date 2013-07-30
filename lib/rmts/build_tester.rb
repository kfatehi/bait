require 'rmts'
require 'rmts/build'
require 'git'
require 'logger'

module Rmts
  class BuildTester
    def initialize build
      @build = build
      logfile = FileUtils.touch File.join(sandbox_directory, 'git.log')
      @log = Logger.new(logfile.last)
    end

    def sandbox_contents
      Dir.glob(File.join(self.sandbox_directory, "*"))
    end

    def clone!
      # path = File.join(sandbox_directory, @build.name)
      # FileUtils.mkdir_p File.join(path, ".git")
      @git ||= Git.open(sandbox_directory, log: @log)
      @git.clone
    end

    def sandbox_directory
      @sandbox_directory ||= begin
        dir = File.join Rmts.storage_dir, "build_tester", @build.id
        FileUtils.mkdir_p(dir) && dir
      end
    end
  end
end
