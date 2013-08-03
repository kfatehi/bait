require 'bait/app'

describe Bait::App do
  specify ".add_subscriber" do
    Bait::App.add_subscriber :foo, :bar
  end
end
