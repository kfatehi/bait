require 'json'

module Bait
  class << self
    @@Subscribers = []
    def add_subscriber stream
      @@Subscribers << stream
    end
    def remove_subscriber stream
      @@Subscribers.delete stream        
    end
    def broadcast *args
      @@Subscribers.each do |out|
        out << "data: #{args.to_json}\n\n"
      end
    end
  end
end
