require 'sinatra'
require 'sinatra/streaming'
require 'sinatra/asset_snack'
require 'haml'
require 'json'
require 'bait/pubsub'
require 'bait/build'

module Bait
  class Api < Sinatra::Base
    register Sinatra::AssetSnack
    set :port, 8417
    set server: 'thin'

    asset_map '/javascript/application.js', ['assets/js/**/*.js', 'assets/js/**/*.coffee']
    asset_map '/stylesheets/application.css', ['assets/stylesheets/**/*.css', 'assets/stylesheets/**/*.scss']

    get '/' do
      redirect '/build'
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
      @builds = Bait::Build.all
      haml :builds
    end

    post '/build/create' do
      build = Build.create({
        clone_url:params["clone_url"],
        name:params["clone_url"].split('/').last
      })
      build.test_later
      redirect '/build'
    end

    get '/build/:id/remove' do
      Build.destroy params["id"]
      redirect '/build'
    end

    get '/build/:id/retest' do
      build = Build.find params['id']
      build.tested = false
      build.output = ""
      build.save
      build.test_later
      redirect '/build'
    end

    helpers Sinatra::Streaming

    get '/build/:id/events', provides: 'text/event-stream' do
      if build = Build.find(params['id'])
        stream(:keep_open) do |out|
          Bait.add_subscriber build.id, out
          out.callback do
            Bait.remove_subscriber build.id, out
          end
        end
      end
    end

    get '/events', provides: 'text/event-stream' do
      stream(:keep_open) do |out|
        Bait.add_subscriber :global, out
        out.callback do
          Bait.remove_subscriber :global, out
        end
      end
    end
  end
end
