require 'spec_helper'
require 'bait/tester'

describe Bait::Tester do
  let(:build) { Bait::Build.create(name: "bait", clone_url:repo_path) }
  let(:tester) { Bait::Tester.new }

  describe "#perform" do
    subject { build.reload }
    before { build.clone! }

    describe "real-time events" do
      before do
        write_script_with_status build.script("test"), 0
      end
      it "push updates directly to the browser" do
        Bait.should_receive(:broadcast).with(:build, :status, build.id, 'testing')
        Bait.should_receive(:broadcast).with(:build, :output, build.id, kind_of(String))
        Bait.should_receive(:broadcast).with(:build, :status, build.id, 'passed')
        tester.perform build.id
      end
    end

    context "build repo did not have a test script" do
      before do
        FileUtils.rm build.script("test")
        tester.perform build.id
      end
      it "has errors in output" do
        build.reload.output.should match /was expected but is missing/
      end
      it "has a useful status" do
        build.reload.status.should eq "script missing"
      end
    end

    context "has a test script" do
      before do
        write_script_with_status build.script('test'), status
        tester.perform build.id
      end

      shared_examples_for "a test run" do
        it "saves output into the build" do
          build.reload.output.should match "this is a test script"
        end
      end

      context "successful" do
        let(:status) { 0 }
        it { should be_passed }
        it_behaves_like "a test run"
      end
      context 'failure' do
        let(:status) { 1 }
        it { should_not be_passed }
        it_behaves_like "a test run"
      end
    end
  end
end
