require 'bait'
require 'sinatra'
require 'sinatra/streaming'
require 'haml'
require 'json'
require 'bait/pubsub'
require 'bait/build'

module Bait
  class Api < Sinatra::Base
    set :port, 8417
    set server: 'thin'

    def self.new(*)
      if $HTTP_AUTH
        puts "** Using HTTP Digest Auth"
        app = Rack::Auth::Digest::MD5.new(super) do |username|
          {$HTTP_AUTH[:username] => $HTTP_AUTH[:password]}[username]
        end
        app.realm = 'Protected Area'
        app.opaque = 'secretkey'
      else
        app
      end
    end

    if Bait.assets.dynamic?
      Bait.assets.remove!
      require 'sinatra/asset_snack'
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
        }).integrate_later
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
      build.integrate_later
    end

    delete '/build/:id' do
      Build.destroy params["id"]
    end

    post '/build/:id/retest' do
      build = Build.find params['id']
      build.integrate_later
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

    ##
    # SimpleCov Passthrough
    get '/build/:id/coverage/*' do
      build = Build.find params[:id]
      if build.simplecov
        send_file File.join(build.coverage_dir, params[:splat])
      end
    end
  end
end
