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
    attribute :passed, Boolean
    attribute :output, String, default: ""
    attribute :tested, Boolean, default: false
    attribute :testing, Boolean, default: false

    validates_presence_of :name
    validates_presence_of :clone_url

    after_destroy :cleanup!

    def test!
      Open3.popen2e(self.script) do |stdin, oe, wait_thr|
        self.testing = true
        self.save
        oe.each do |line|
          self.output << line
          Bait.broadcast(self.id, {category: :output, output: line})
        end
        self.passed = wait_thr.value.exitstatus == 0
      end
      self.tested = true
    rescue Errno::ENOENT => ex
      self.output << "A test script was expected but missing.\nError: #{ex.message}"
    ensure
      self.testing = false
      self.save
      Bait.broadcast(self.id, {category: :status, status: status})
    end

    def test_later
      self.tested = false
      self.save
      Bait::Tester.new.async.perform(self.id) unless Bait.env == "test"
      self
    end

    def queued?
      self.reload
      !self.testing? && !self.tested?
    end

    def status
      if queued?
        "queued"
      elsif testing?
        "testing"
      elsif passed?
        "passed"
      else
        "failed"
      end
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
      Bait.broadcast(self.id, {category: :removal})
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
  end
end
