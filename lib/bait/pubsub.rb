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
    def get_subscribers channel=nil
      if channel
        @@Subscribers[channel]
      else
        @@Subscribers
      end
    end
    def broadcast channel, data
      if subscribers = @@Subscribers[channel]
        subscribers.each do |out|
          out << "data: #{data.to_json}\n\n"
        end
      end
    end
  end
end
