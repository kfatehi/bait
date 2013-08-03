ENV['RACK_ENV'] = "test"
require 'simplecov'
SimpleCov.start

# Use simplecov with forking specs
pid = Process.pid
SimpleCov.at_exit do
  SimpleCov.result.format! if Process.pid == pid
end

require 'bait'
require 'fileutils'

def repo_path
  path = File.join(File.dirname(__FILE__), '..')
  File.expand_path(path)
end

def clear_storage
  FileUtils.rm_rf Bait.storage_dir
end

def clear_db
  Dir.glob(File.join(Bait.db_dir, "*")).map do |f|
    File.open(f, 'w')
  end
end

require 'support/script_maker'
require 'rack/test'

RSpec.configure do |config|
  config.before(:suite) { clear_storage }
  config.before(:each) { clear_db }
  config.include Bait::SpecHelpers::ScriptMaker
  config.include Rack::Test::Methods
end
