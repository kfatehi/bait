require 'rmts'
require 'moneta'
require "toystore"


module Rmts
  class Build
    include Toy::Store
    @@db_file = Rmts.db_file('builds')
    adapter :memory, Moneta.new(:YAML, :file => @@db_file)

    attribute :name, String

    after_create :check_into_store

    def check_into_store
      build_ids = Build.ids
      build_ids << self.id
      Build.ids = build_ids
    end

    class << self
      def ids
        Rmts.store.raw["build_ids"] ||= []
      end

      def ids=(new_ids)
        Rmts.store.raw["build_ids"] = new_ids
      end

      def all
        ids.map{|id| Build.read(id)}
      end

      def last
        Build.read(Build.ids.last)
      end
    end
  end
end
