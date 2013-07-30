require 'bait'
require 'moneta'
require "toystore"
require 'bait/simple_query'
require 'bait/tester'

module Bait
  class Build
    extend Bait::SimpleQuery
    include Toy::Store
    @@db_file = Bait.db_file('builds')
    adapter :memory, Moneta.new(:YAML, :file => @@db_file)

    attribute :ref, String
    attribute :owner_name, String
    attribute :owner_email, String
    attribute :name, String
    attribute :clone_url, String
    attribute :passed, Boolean
    attribute :stdout, String
    attribute :stderr, String
    attribute :tested, Boolean

    validates_presence_of :name
    validates_presence_of :clone_url

    def tester
      @tester ||= Bait::Tester.new(self)
    end

    def test_later
      self.tested = false
      self.save
      unless Bait.env == "test"
        fork do
          self.tester.clone!
          self.tester.test!
        end
      end
      self
    end

    # TODO
    # Make the check_into_store part of Bait::SimpleQuery
    after_create :check_into_store

    before_destroy :checkout_from_store

    private

    def check_into_store
      build_ids = Build.ids
      build_ids << self.id
      Build.ids = build_ids
    end

    def checkout_from_store
      Build.ids = Build.ids.reject{|id| id == self.id}
    end
  end
end
