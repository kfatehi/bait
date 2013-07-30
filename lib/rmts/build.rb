require 'rmts'
require 'moneta'
require "toystore"
require 'rmts/simple_query'
require 'rmts/build_tester'

module Rmts
  class Build
    extend Rmts::SimpleQuery
    include Toy::Store
    @@db_file = Rmts.db_file('builds')
    adapter :memory, Moneta.new(:YAML, :file => @@db_file)

    attribute :name, String
    attribute :clone_url, String

    def tester
      @tester ||= Rmts::BuildTester.new(self)
    end


    # TODO
    # Make the check_into_store part of Rmts::SimpleQuery
    after_create :check_into_store
    
    private
    
    def check_into_store
      build_ids = Build.ids
      build_ids << self.id
      Build.ids = build_ids
    end
  end
end
