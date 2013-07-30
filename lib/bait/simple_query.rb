module Bait
  module SimpleQuery
    def ids
      Bait.store.raw["build_ids"] ||= []
    end

    def ids=(new_ids)
      Bait.store.raw["build_ids"] = new_ids
    end

    def all
      ids.map{|id| self.read(id)}
    end

    def last
      self.read(self.ids.last)
    end
  end
end

