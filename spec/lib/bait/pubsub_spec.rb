require 'bait/pubsub'

describe Bait do
  describe ".broadcast" do
    let (:channel) { "test channel" }
    let (:stream) { double(:stream) }
    context 'one subscriber' do
      before { Bait.add_subscriber channel, stream }
      it "broadcasts data to the subscriber" do
        stream.should_receive(:<<).with(kind_of(String))
        Bait.broadcast channel, {foo: :bar}
      end
    end
  end
end

