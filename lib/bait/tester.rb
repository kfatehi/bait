require 'bait'
require 'bait/build'
require 'git'
require 'pty'

module Bait
  class Tester
    attr_reader :passed

    def initialize build
      @build = build
    end

    def bait_dir
      File.join(clone_path, ".bait")
    end

    def script
      File.join(bait_dir, "test.sh")
    end

    def test!
      begin
        begin
          PTY.spawn(script) do |r, w, pid|
            r.each { |line| @build.output << line }
            @build.passed = PTY.check(pid).exitstatus == 0
          end
        rescue PTY::ChildExited => e
          @build.output << e
          @build.passed = false
        end
        @build.tested = true
      rescue Errno::ENOENT => ex
        @build.output << "A test script was expected but missing.\nError: #{ex.message}"
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
          @build.output << "#{msg}\n\n#{ex.message}\n\n#{ex.backtrace}"
          @build.save
        end
      end
    end

    def cloned?
      Dir.exists? File.join(clone_path, ".git/")
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
