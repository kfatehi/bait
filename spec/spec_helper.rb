ENV['RACK_ENV'] = "test"

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rmts'
require 'rspec'
require 'sinatra'
require 'rack/test'
require 'fileutils'

def clear_storage
  FileUtils.rm_rf Rmts.storage_dir
end

def clear_db
  Dir.glob(File.join(Rmts.db_dir, "*")).map do |f|
    File.open(f, 'w')
  end
end

RSpec.configure do |config|
  config.before(:suite) { clear_storage }
  config.before(:each) { clear_db }
  config.include Rack::Test::Methods
end
