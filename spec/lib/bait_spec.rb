require 'spec_helper'
require 'bait'

describe Bait do
  it 'should have a version number' do
    Bait::VERSION.should_not be_nil
  end

  describe "#public" do
    it "returns a Pathname" do
      Bait.public.should be_a Pathname
    end
    it "returns the app public path" do
      Bait.public.to_s.split('/').last.should eq "public"
    end
    it "returns a real path" do
      Bait.public.should exist
    end
  end

  describe "#assets" do
    describe "#missing?" do
      subject { Bait.assets }
      context "when assets are missing" do
        before do
          Bait.assets.remove!
        end
        it { should be_missing }
      end
      context "when assets are compiled" do
        before do
          Bait.assets.remove!
          Bait.assets.compile!
        end
        it { should_not be_missing }
      end
    end
  end

  describe "#console" do
    it "provides access to STDOUT" do
      Bait.console.should eq STDOUT
    end
  end
end
