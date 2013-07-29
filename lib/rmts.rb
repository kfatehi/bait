require "rmts/version"
require 'moneta'

# Person.adapter :memory, Moneta.new(:File, :dir => 'moneta')

module Rmts
  def self.db_dir
    path = File.join("#{self.home}", "#{self.env}")
    FileUtils.mkdir_p path
  end

  def self.db_file name
    yaml_file = File.join Rmts.db_dir, "#{name}.yaml"
    FileUtils.touch yaml_file
    yaml_file
  end

  def self.store
    @store ||= begin
      Moneta.new :YAML, :file => db_file("rmts")
    end
  end

  def self.env
    ENV['RACK_ENV'] ||= 'production'
  end

  def self.home
    File.join Etc.getpwuid.dir, '.rmts'
  end
end

