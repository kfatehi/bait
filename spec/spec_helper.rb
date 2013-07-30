ENV['RACK_ENV'] = "test"
require 'simplecov'
SimpleCov.start

require 'rmts'
require 'fileutils'

def clear_storage
  FileUtils.rm_rf Rmts.storage_dir
end

def clear_db
  Dir.glob(File.join(Rmts.db_dir, "*")).map do |f|
    File.open(f, 'w')
  end
end

require 'support/script_maker'
require 'rack/test'

RSpec.configure do |config|
  config.before(:suite) { clear_storage }
  config.before(:each) { clear_db }
  config.include Rmts::SpecHelpers::ScriptMaker
  config.include Rack::Test::Methods
end
