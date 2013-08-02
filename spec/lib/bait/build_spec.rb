require 'spec_helper'
require 'bait/build'

describe Bait::Build do
    subject { Bait::Build }

  describe ".all" do
    context "with nothing in the store" do
      specify { subject.all.should be_empty }
    end

    context "with builds in the store" do
      before do
        subject.create(name: "foo", clone_url:'...')
        subject.create(name: "bar", clone_url:'...')
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
        subject.create(name: "fud", clone_url:'...')
        @build = subject.create(name: "baz", clone_url:'...')
      end
      it "returns the last created build" do
        subject.last.name.should eq "baz"
      end
    end
  end

  let (:build) { Bait::Build.create(name: "app", clone_url:'...') }

  describe "#test_later" do
    it "forks in order to clone and test" do
      build.should_receive(:fork) do |&block|
        build.tester.should_receive(:clone!)
        build.tester.should_receive(:test!)
        block.call
      end
      build.test_later
    end
  end

  describe "#tester" do
    specify { build.tester.should be_a Bait::Tester }
  end

  describe "#passed" do
    it "starts as nil" do
      build.passed.should be_nil
    end
  end

  describe "removal" do
    before do
      @build = build
    end

    it "is removed from build ids" do
      Bait::Build.ids.should have(1).item
      @build.destroy
      Bait::Build.ids.should be_empty
    end
  end

  describe "#queued" do
    subject { build }
    context "already tested" do
      before { build.tested = true ; build.save }
      it { should_not be_queued }
    end

    context "not tested" do
      before { build.tested = false ; build.save }
      it { should be_queued }
    end
  end

  describe "#status" do
    subject { build.reload.status }
    context 'queued' do
      before do
        build.tested = false
        build.save
      end
      it { should eq "queued" }
    end
    context 'passed' do
      before do
        build.tested = true
        build.passed = true
        build.save
      end
      it { should eq "passed" }
    end
    context 'failed' do
      before do
        build.tested = true
        build.passed = false
        build.save
      end
      it { should eq "failed" }
    end
  end
end
