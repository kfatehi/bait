require 'bait'
require 'bait/build'
require 'git'
require 'logger'
require 'open3'

module Bait
  class Tester
    attr_reader :passed

    def initialize build
      @build = build
      @cloned = false
    end

    def bait_dir
      File.join(clone_path, ".bait")
    end

    def script
      File.join(bait_dir, "test.sh")
    end

    def test!
      begin
        stdout, stderr, s = Open3.capture3(script)
        @build.tested = true
        @build.passed = s.exitstatus == 0
        @build.stdout = stdout
        @build.stderr = stderr
      rescue Errno::ENOENT => ex
        @build.stderr = "A test script was expected but missing.\nError: #{ex.message}"
      ensure
        @build.save
      end
    end

    def clone_path
      File.join(sandbox_directory, @build.name)
    end

    def clone!
      unless cloned?
        begin
          Git.clone(@build.clone_url, @build.name, :path => sandbox_directory)
        rescue => ex
          msg = "Failed to clone #{@build.clone_url}"
          puts msg
          @build.stderr = "#{msg}\n\n#{ex.message}\n\n#{ex.backtrace}"
          @build.save
        end
        @cloned = Dir.exists? File.join(clone_path, ".git/")
      end
    end

    def cloned?
      @cloned
    end

    def cleanup!
      FileUtils.rm_rf sandbox_directory
    end

    def sandbox_directory
      @sandbox_directory ||= begin
        dir = File.join Bait.storage_dir, "build_tester", @build.id
        FileUtils.mkdir_p(dir) && dir
      end
    end
  end
end