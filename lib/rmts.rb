require "rmts/version"
require 'moneta'

module Rmts
  def self.storage_dir
    path = File.join("#{self.home}", "#{self.env}")
    FileUtils.mkdir_p path
    path
  end

  def self.db_dir
    db_dir = File.join Rmts.storage_dir, "databases"
    FileUtils.mkdir_p db_dir
    db_dir
  end

  def self.db_file name
    yaml_file = File.join self.db_dir, "#{name}.yaml"
    FileUtils.touch yaml_file
    yaml_file
  end

  def self.store
    @store ||= begin
      Moneta.new :YAML, :file => db_file("main")
    end
  end

  def self.env
    ENV['RACK_ENV'] ||= 'production'
  end

  def self.home
    File.join Etc.getpwuid.dir, '.rmts'
  end
end

