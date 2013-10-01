require "bait/version"
require 'moneta'
require 'fileutils'
require 'bait/assets'
require 'pathname'
require 'term/ansicolor'

class String
  include Term::ANSIColor
end

module Bait
  class << self
    include Bait::Assets

    def storage_dir
      path = File.join("#{home}", "#{env}")
      FileUtils.mkdir_p path
      path
    end

    def db_dir
      db_dir = File.join storage_dir, "databases"
      FileUtils.mkdir_p db_dir
      db_dir
    end

    def db_file name
      yaml_file = File.join db_dir, "#{name}.yaml"
      FileUtils.touch yaml_file
      yaml_file
    end

    def store
      @store ||= begin
        Moneta.new :YAML, :file => db_file("main")
      end
    end

    def env
      ENV['RACK_ENV'] ||= 'production'
    end

    def home
      File.join Etc.getpwuid.dir, '.bait'
    end

    def public
      Pathname.new(File.join(File.dirname(__FILE__), 'bait', 'public'))
    end

    def console
      STDOUT
    end
  end
end

