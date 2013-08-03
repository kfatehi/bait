require 'celluloid'

module Bait
  class JobQueue
    include Celluloid

    def initialize
      @queue = []
    end
  end


  class App
    @@toy_reporters = {}
    @@job_queue = Bait::JobQueue.new
    def self.add_subscriber toy_id, subscriber
      if @@toy_reporters[toy_id]
        @@toy_reporters[toy_id].add_subscriber(subscriber)
      end
    end

    def self.start
      Bait::Build.all.select{|b| b.queued?}
    end
  end
end
