require 'bait/pubsub'

describe Bait do
  describe ".broadcast" do
    let (:channel) { "test channel" }
    let (:stream) { double(:stream) }
    let (:format) { "data: [\"foo\",\"bar\",\"baz\"]\n\n" }
    context 'one subscriber' do
      before { Bait.add_subscriber channel, stream }
      it "broadcasts data to the subscriber" do
        stream.should_receive(:<<).with(format)
        Bait.broadcast channel, :foo, :bar, :baz
      end
    end
  end
end

