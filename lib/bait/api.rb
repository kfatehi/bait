require 'bait'
require 'sinatra'
require 'sinatra/streaming'
require 'haml'
require 'json'
require 'bait/pubsub'
require 'bait/build'

unless Bait.env == "production"
  require 'sinatra/asset_snack' 
  DYNAMIC_ASSETS = true
  require 'fileutils'
  public = File.join File.dirname(__FILE__), %w(public)
  [%w(js application.js), %w(css application.css)].each do |i|
    path = File.join(public, i)
    FileUtils.rm(path) if File.exists?(path)
  end
end

module Bait
  class Api < Sinatra::Base
    set :port, 8417
    set server: 'thin'

    if defined? DYNAMIC_ASSETS
      register Sinatra::AssetSnack
      asset_map '/js/application.js', ['app/js/**/*.js', 'app/js/**/*.coffee']
      asset_map '/css/application.css', ['app/css/**/*.css', 'app/css/**/*.scss']
    end

    get '/' do
      haml :builds
    end

    post '/' do
      if params && params["payload"]
        push = JSON.parse(params["payload"])
        Build.create({
          name: push["repository"]["name"],
          clone_url: push["repository"]["url"],
          owner_name: push["repository"]["owner"]["name"],
          owner_email: push["repository"]["owner"]["email"],
          ref: push["ref"]
        }).test_later
      end
    end

    get '/build' do
      content_type :json
      @builds = Bait::Build.all
      @builds.to_json
    end

    post '/build/create' do
      build = Build.create({
        clone_url:params["clone_url"],
        name:params["clone_url"].split('/').last
      })
      build.test_later
    end

    delete '/build/:id' do
      Build.destroy params["id"]
    end

    post '/build/:id/retest' do
      build = Build.find params['id']
      build.test_later
    end

    helpers Sinatra::Streaming

    get '/events', provides: 'text/event-stream' do
      stream(:keep_open) do |out|
        Bait.add_subscriber out
        out.callback do
          Bait.remove_subscriber out
        end
      end
    end
  end
end
