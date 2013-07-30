require 'rmts'
require 'rmts/build'
require 'git'
require 'logger'
require 'open3'

module Rmts
  class BuildTester
    attr_reader :passed

    def initialize build
      @build = build
      @cloned = false
    end

    def rmts_dir
      File.join(clone_path, ".rmts")
    end

    def script
      File.join(rmts_dir, "test.sh")
    end

    def test!
      stdout, stderr, s = Open3.capture3(script)
      @build.passed = s.exitstatus == 0
      @build.stdout = stdout
      @build.stderr = stderr
      @build.save
    end

    def clone_path
      File.join(sandbox_directory, @build.name)
    end

    def clone!
      unless cloned?
        Git.clone(@build.clone_url, @build.name, :path => sandbox_directory)
        @cloned = Dir.exists? File.join(clone_path, ".git/")
      end
    end

    def cloned?
      @cloned
    end

    def sandbox_contents
      Dir.glob(File.join(self.sandbox_directory, "*"))
    end

    def sandbox_directory
      @sandbox_directory ||= begin
        dir = File.join Rmts.storage_dir, "build_tester", @build.id
        FileUtils.mkdir_p(dir) && dir
      end
    end
  end
end
