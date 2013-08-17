require 'spec_helper'
require 'bait/integrator'

describe Bait::Integrator do
  let(:build) { Bait::Build.create(name: "bait", clone_url:repo_path) }
  let(:worker) { Bait::Integrator.new }

  describe "#perform" do
    subject { build.reload }
    before { build.clone! }

    describe "real-time events" do
      before do
        write_script_with_status build.script("test.sh"), 0
      end
      it "push updates directly to the browser" do
        Bait.should_receive(:broadcast).with(:build, :status, build.id, 'phase: test.sh')
        Bait.should_receive(:broadcast).with(:build, :output, build.id, kind_of(String))
        Bait.should_receive(:broadcast).with(:build, :status, build.id, 'passed')
        worker.perform build.id
      end
    end

    context "build repo did not have a test script" do
      before do
        FileUtils.rm build.script("test.sh")
        FileUtils.rm build.script("coffeelint.rb")
        worker.perform build.id
      end
      it "has errors in output" do
        build.reload.output.should match /was expected but is missing/
      end
      it "has a useful status" do
        build.reload.status.should eq "missing: coffeelint.rb"
      end
    end

    context "has a test script" do
      before do
        write_script_with_status build.script('test.sh'), status
        worker.perform build.id
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
