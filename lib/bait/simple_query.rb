module Bait
  module SimpleQuery
    def self.extended(base)
      base.after_create do
        id_list = self.class.ids
        id_list << self.id
        self.class.ids = id_list
      end
      base.after_destroy do
        self.class.ids = self.class.ids.reject{|id| id == self.id}
      end
    end

    def id_list_key
      "#{self.name.split('::').last.downcase}_ids"
    end

    def ids
      Bait.store.raw[id_list_key] ||= []
    end

    def ids=(new_ids)
      Bait.store.raw[id_list_key] = new_ids
    end

    def all
      ids.map{|id| self.read(id)}
    end

    def last
      self.read(self.ids.last)
    end
  end
end

