

module Bait
  class App
    @@toy_reporters = {}
    def self.add_subscriber toy_id, subscriber
      if @@toy_reporters[toy_id]
        @@toy_reporters[toy_id].add_subscriber(subscriber)
      end
    end
  end
end
