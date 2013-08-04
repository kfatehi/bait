require 'bait/object'
require 'bait/tester'
require 'json'
require 'bait/pubsub'

module Bait
  class Build < Bait::Object
    adapter :memory,
      Moneta.new(:YAML, :file => Bait.db_file('builds'))

    attribute :ref, String
    attribute :owner_name, String
    attribute :owner_email, String
    attribute :name, String
    attribute :clone_url, String
    attribute :output, String, default: ""
    attribute :status, String, default: "queued"

    validates_presence_of :name
    validates_presence_of :clone_url

    after_create do
      Bait.broadcast(:global, :new_build, self)
    end

    after_destroy do
      self.broadcast(:remove)
      self.cleanup!
    end

    def test!
      Open3.popen2e(self.script) do |stdin, oe, wait_thr|
        self.status = "testing"
        self.broadcast :status, self.status
        self.save
        oe.each do |line|
          self.output << line
          self.broadcast(:output, line)
        end
        if wait_thr.value.exitstatus == 0
          self.status = "passed"
        else
          self.status = "failed"
        end
      end
    rescue Errno::ENOENT => ex
      self.output << "A test script was expected but missing.\nError: #{ex.message}"
      self.status = "script missing"
    ensure
      self.save
      self.broadcast(:status, status)
    end

    def test_later
      self.status = "queued"
      self.output = ""
      self.save
      Bait::Tester.new.async.perform(self.id) unless Bait.env == "test"
      self
    end

    def queued?
      self.reload.status == "queued"
    end

    def passed?
      self.reload.status == "passed"
    end

    def clone_path
      File.join(sandbox_directory, self.name)
    end

    def bait_dir
      File.join(clone_path, ".bait")
    end

    def script
      File.join(bait_dir, "test.sh")
    end
    
    def cloned?
      Dir.exists? File.join(clone_path, ".git/")
    end

    def cleanup!
      FileUtils.rm_rf(sandbox_directory) if Dir.exists?(sandbox_directory)
    end

    def sandbox_directory
      File.join Bait.storage_dir, "tester", self.name, self.id
    end

    def clone!
      unless cloned?
        unless Dir.exists?(sandbox_directory)
          FileUtils.mkdir_p sandbox_directory
        end
        begin
          Git.clone(clone_url, name, :path => sandbox_directory)
        rescue => ex
          msg = "Failed to clone #{clone_url}"
          self.output << "#{msg}\n\n#{ex.message}\n\n#{ex.backtrace.join("\n")}"
          self.save
        end
      end
    end

    protected

    def broadcast attr, *args
      Bait.broadcast :build, attr, self.id, *args
    end
  end
end
