require 'spec_helper'
require 'rmts/build'

describe Rmts::Build do
    subject { Rmts::Build }

  describe ".all" do
    context "with nothing in the store" do
      specify { subject.all.should be_a Array }
    end

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
    context "with nothing in the store" do
      specify { subject.last.should be_nil }
    end
    context "with builds in the store" do
      before do
        subject.create(name: "fud")
        @build = subject.create(name: "baz")
      end
      it "returns the last created build" do
        subject.last.name.should eq "baz"
      end
    end
  end

  let (:build) { Rmts::Build.create(name: "app") }

  describe "#tester" do
    specify { build.tester.should be_a Rmts::Tester }
  end

  describe "#passed" do
    it "starts as nil" do
      build.passed.should be_nil
    end
  end
end
