require 'bait'
require 'bait/build'
require 'git'
require 'open3'

module Bait
  class TestJob
  end
end

module Bait
  class Tester
    include Celluloid

    def perform(build_id)
      puts "Actor was told to perform"
      if @build = ::Bait::Build.find(build_id)
        puts "Found build"
        clone!
        test!
        self.terminate
      else
        puts "Build not found with id #{build_id}"
      end
    end

    attr_reader :passed

    def bait_dir
      File.join(clone_path, ".bait")
    end

    def script
      File.join(bait_dir, "test.sh")
    end

    def test!
      Open3.popen2e(script) do |stdin, oe, wait_thr|
        @build.running = true
        @build.save
        oe.each {|line| @build.output << line }
        @build.passed = wait_thr.value.exitstatus == 0
        @build.running = false
      end
      @build.tested = true
    rescue Errno::ENOENT => ex
      @build.output << "A test script was expected but missing.\nError: #{ex.message}"
    ensure
      @build.save
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
