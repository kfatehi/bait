require 'sinatra'
require 'haml'
require 'json'
require 'bait/build'

module Bait
  class Api < Sinatra::Base
    set :port, 8417

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

    get '/build/remove/:id' do
      Build.destroy params["id"]
      redirect '/build'
    end

    get '/build/retest/:id' do
      build = Build.find params['id']
      build.tested = false
      build.output = ""
      build.test_later
      build.save
      redirect '/build'
    end
  end
end
