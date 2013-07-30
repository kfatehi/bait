require 'sinatra'
require 'haml'
require 'json'
require 'bait/build'

module Bait
  class Api < Sinatra::Base
    get '/' do
      redirect '/build'
    end

    post '/' do
      if params && params["payload"]
        push = JSON.parse(params["payload"])
        Bait::Build.create({
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
      build = Bait::Build.create(clone_url:params["clone_url"], name:'test')
      build.test_later
      redirect '/build'
    end

    get '/build/remove/:id' do
      Build.delete params["id"]
      redirect '/build'
    end
  end
end
