require 'rmts'
require 'rmts/build'
require 'git'
require 'logger'
require 'open3'

module Rmts
  class BuildTester
    class NotClonedError < StandardError ; end
    class NoRmtsDirError < StandardError ; end
    class NoTestScriptError < StandardError ; end
    attr_reader :passed

    def initialize build
      @build = build
      @cloned = false
      @passed = nil
    end

    def rmts_dir
      required_path clone_path, ".rmts", NoRmtsDirError
    end

    def rmts_test_script
      required_path rmts_dir, "test.sh", NoTestScriptError
    end

    def test!
      raise NotClonedError unless cloned?
      out, err, status = Open3.capture3(rmts_test_script)
      require 'pry'; binding.pry
      
      @passed = false
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

    private

    def required_path parent, name, error=StandardError
      path = File.join(parent, name)
      if File.exists?(path)
        path
      else
        raise error
      end
    end
  end
end
