require 'json'

module Bait
  class << self
    @@Subscribers = {}
    def add_subscriber channel, stream
      @@Subscribers[channel] ||= []
      @@Subscribers[channel] << stream
    end
    def remove_subscriber channel, stream
      if @@Subscribers[channel]
        @@Subscribers[channel].delete stream        
      end
    end
    def broadcast channel, *args
      if subscribers = @@Subscribers[channel]
        subscribers.each do |out|
          out << "data: #{args.to_json}\n\n"
        end
      end
    end
  end
end
