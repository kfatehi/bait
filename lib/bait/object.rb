require 'moneta'
require "toystore"
require 'bait/simple_query'

module Bait
  class Object
    include Toy::Store
    extend Bait::SimpleQuery
  end
end

