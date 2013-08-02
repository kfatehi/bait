require 'bait/object'
require 'bait/tester'

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

    validates_presence_of :name
    validates_presence_of :clone_url

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

    after_destroy  { tester.cleanup! }
  end
end
