require 'sinatra'
require 'haml'
require 'json'
require 'rmts/build'

module Rmts
  class Api < Sinatra::Base
    post '/' do
      if params && params["payload"]
        push = JSON.parse(params["payload"])
        Rmts::Build.create({
          name: push["repository"]["name"],
          clone_url: push["repository"]["url"],
          owner_name: push["repository"]["owner"]["name"],
          owner_email: push["repository"]["owner"]["email"],
          ref: push["ref"]
        }).test_later
      end
    end

    get '/' do
      @builds = Rmts::Build.all
      haml :builds
    end
  end
end
