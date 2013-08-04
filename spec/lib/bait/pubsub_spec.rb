require 'bait/pubsub'

describe Bait do
  describe ".broadcast" do
    let (:stream) { double(:stream) }
    let (:format) { "data: [\"foo\",\"bar\",\"baz\"]\n\n" }
    context 'one subscriber' do
      before { Bait.add_subscriber stream }
      it "broadcasts data to the subscriber" do
        stream.should_receive(:<<).with(format)
        Bait.broadcast :foo, :bar, :baz
      end
      after { Bait.remove_subscriber stream }
    end
  end
end

