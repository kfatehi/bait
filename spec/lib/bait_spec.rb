require 'spec_helper'

describe Bait do
  it 'should have a version number' do
    Bait::VERSION.should_not be_nil
  end
end
