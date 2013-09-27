require 'bait/object'
require 'bait/integrator'
require 'bait/build_helper'
require 'bait/simplecov_support'
require 'bait/pubsub'
require 'bait/phase'
require 'json'
require 'yaml'

module Bait
  class Build < Bait::Object
    include Bait::BuildHelper
    include Bait::SimpleCovSupport

    adapter :memory,
      Moneta.new(:YAML, :file => Bait.db_file('builds'))

    attribute :simplecov, Boolean, default: false
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

    def phases
      YAML.load_file(File.join(self.bait_dir, "config.yml"))
    end

    def enter_phase name
      Bait::Phase.new(self.script(name)).on(:init) do
        self.broadcast(:status, "phase: #{name}")
      end.on(:output) do |line|
        self.output << line
        self.broadcast(:output, line)
      end.on(:missing) do |message|
        self.output << message
        self.broadcast(:status, "missing: #{name}")
        self.save
      end.on(:done) do |zerostatus|
        unless self.status == "failed"
          if zerostatus
            self.status = "passed"
          else
            self.status = "failed"
          end
          self.save
          check_for_simplecov
        end
        self.broadcast(:status, self.status)
      end.run!
    end

    def integrate_later
      self.status = "queued"
      self.output = ""
      self.save
      Bait::Integrator.new.async.perform(self.id) unless Bait.env == "test"
      self
    end

    def clone!
      return if cloned?
      unless Dir.exists?(sandbox_directory)
        FileUtils.mkdir_p sandbox_directory
      end
      begin
        Git.clone(clone_url, name, :path => sandbox_directory)
      rescue => ex
        msg = "Failed to clone #{clone_url}"
        self.output << "#{msg}\n\n#{ex.message}\n\n#{ex.backtrace.join("\n")}"
        self.status = "failed to clone"
        self.save
      end
    end

    protected

    def broadcast attr, *args
      Bait.broadcast :build, attr, self.id, *args
    end
  end
end
