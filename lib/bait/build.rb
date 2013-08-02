require 'bait/object'
require 'bait/tester'
require 'json'
require 'httparty'

module Bait
  class Build < Bait::Object
    adapter :memory,
      Moneta.new(:YAML, :file => Bait.db_file('builds'))

    attribute :ref, String
    attribute :owner_name, String
    attribute :owner_email, String
    attribute :name, String
    attribute :clone_url, String
    attribute :passed, Boolean
    attribute :output, String, default: ""
    attribute :tested, Boolean, default: false
    attribute :running, Boolean, default: false

    validates_presence_of :name
    validates_presence_of :clone_url

    before_save do
      unless changes.empty?
        data = changes
        data['status'] = self.status
        data['id'] = self.id
        if run = changes['running']
          if run[0] && run[1] == false
            data['output'] = self.output
          end
        end
        HTTParty.put("http://127.0.0.1:8417/build/#{self.id}/event/publish",
          query:{ event:"message", data:data.to_json})
      end
    end

    after_destroy  { tester.cleanup! }

    def tester
      @tester ||= Bait::Tester.new(self)
    end

    def test_later
      self.tested = false
      self.save
      fork do
        self.tester.clone!
        self.tester.test!
      end
      self
    end

    def queued?
      !self.reload.tested?
    end

    def status
      if queued?
        "queued"
      elsif tested?
        passed? ? "passed" : "failed"
      end
    end
  end
end
