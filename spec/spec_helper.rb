$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rmts'
require 'rspec'
require 'sinatra'
require 'rack/test'

require 'pry'

set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
