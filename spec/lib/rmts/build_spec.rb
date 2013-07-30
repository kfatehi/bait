require 'spec_helper'
require 'rmts/build'

describe Rmts::Build do
  describe "class methods" do
    subject { Rmts::Build }

    describe ".all" do
      specify { subject.all.should be_a Array }
      
      context "with builds in the store" do
        before do
          subject.create(name: "foo")
          subject.create(name: "bar")
        end
        
        specify { subject.all.should have(2).items }
        
        it "returns the builds with data" do
          subject.all[0].name.should eq "foo"
          subject.all[1].name.should eq "bar"
        end
      end
    end

    describe ".last" do
      before do
        subject.create(name: "fud")
        @build = subject.create(name: "baz")
      end
      it "returns the last created build" do
        subject.last.name.should eq "baz"
      end
    end
  end

  describe "#tester" do
    it "returns an Rmts::BuildTester" do
      build = Rmts::Build.create(name: "app")
      build.tester.should be_a Rmts::BuildTester
    end
  end
end
