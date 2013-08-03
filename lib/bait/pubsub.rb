require 'json'

module Bait
  class << self
    @@Subscribers = {}
    def add_subscriber channel, stream
      puts "Adding a subscriber"
      @@Subscribers[channel] ||= []
      @@Subscribers[channel] << stream
      puts Bait.num_subscribers(channel).inspect
    end
    def remove_subscriber channel, stream
      puts "Removing a subscriber"
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
    def num_subscribers channel=nil
      get_subscribers(channel).size
    end
    def broadcast channel, data
      if subscribers = @@Subscribers[channel]
        subscribers.each do |out|
          out << "data: #{data.to_json}}\n\n"
        end
      end
    end
  end
end
