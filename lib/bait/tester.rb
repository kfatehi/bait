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
    end

    def bait_dir
      File.join(clone_path, ".bait")
    end

    def script
      File.join(bait_dir, "test.sh")
    end

    def test!
      begin
        data = {out:'', err:''}
        Open3.popen3(script) do |stdin, out, err, external|
          # Create a thread to read from each stream
          { :out => out, :err => err }.each do |key, stream|
            Thread.new do
              until (line = stream.gets).nil? do
                data[key] << line
              end
            end
          end

          # Don't exit until the external process is done
          external.join
          @build.passed = external.value == 0
          @build.tested = true
          @build.stdout = data[:out]
          @build.stderr = data[:err]
        end
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
