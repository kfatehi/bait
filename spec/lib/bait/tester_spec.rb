require 'spec_helper'
require 'bait/tester'

describe Bait::Tester do
  let(:build) { Bait::Build.create(name: "bait", clone_url:repo_path) }
  let(:tester) { Bait::Tester.new }

  describe "#perform" do
    shared_examples_for "a test run" do
      it "saves output into the build" do
        build.reload.output.should match "this is a test script"
      end
      it "is marked as tested" do
        build.reload.should be_tested
      end
    end

    subject { build.reload }
    before { build.clone! }

    context "build repo did not have a test script" do
      before do
        FileUtils.rm build.script
        tester.perform build.id
      end
      it { should_not be_tested }
      it "has errors in output" do
        build.reload.output.should match /script was expected but missing/
      end
    end

    context "has a test script" do
      before do
        write_script_with_status build.script, status
        tester.perform build.id
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
