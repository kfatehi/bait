require 'sinatra'
require 'json'
require 'rmts/build'

module Rmts
  class Api < Sinatra::Base
    post '/' do
      if params && params["payload"]
        push = JSON.parse(params["payload"])
        Rmts::Build.create({
          name: push["repository"]["name"]
        })
      end
    end
  end
end
