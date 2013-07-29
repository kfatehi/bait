ENV['RACK_ENV'] = "test"

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rmts'
require 'rspec'
require 'sinatra'
require 'rack/test'


def clear_db
  Dir.glob(File.join(Rmts.db_dir, "*")).map do |f|
    FileUtils.rm_rf(f)
  end
end

RSpec.configure do |config|
  config.before(:each) { clear_db }
  config.include Rack::Test::Methods
end
