require 'spec_helper'
require 'bait/tester'

describe Bait::Tester do
  let(:repo_path) do
    path = File.join(File.dirname(__FILE__), '..', '..', '..')
    File.expand_path(path)
  end
  let(:build) { Bait::Build.create(name: "bait", clone_url:repo_path) }
  let(:tester) { build.tester }

  describe "#sandbox_directory" do
    it "creates a directory on disk" do
      Dir.exists?(tester.sandbox_directory).should be_true
    end

    it "is beneath Bait storage directory" do
      tester.sandbox_directory.should match Bait.storage_dir
    end
  end

  describe "#cloned?" do
    specify { tester.should_not be_cloned }
  end

  describe "#clone!" do
    before { tester.clone! }
    specify { tester.should be_cloned }
  end

  describe "#test!" do
    shared_examples_for "a test run" do
      it "saves stdout into the build" do
        build.stdout.should eq "this is a test script\n"
      end
      it "saves stderr into the build" do
        build.stderr.should be_empty
      end
      it "is marked as tested" do
        build.should be_tested
      end
    end

    before do
      tester.clone!
    end

    subject { build.reload }

    context "does not have a test script" do
      before do
        FileUtils.rm tester.script
        tester.test!
      end
      it { should_not be_tested }
      it "has Bait errors in stderr" do
        subject.stderr.should match /script was expected but missing/
      end
    end

    context "has a test script" do
      context "successful" do
        before do
          write_script_with_status tester.script, 0
          tester.test!
        end
        it { should be_passed }
        it_behaves_like "a test run"
      end
      context 'failure' do
        before do
          write_script_with_status tester.script, 1
          tester.test!
        end
        it { should_not be_passed }
        it_behaves_like "a test run"
      end
    end
  end

  describe "cleanup!" do
    before do
      tester.clone!
    end
    it "removes the entire sandbox" do
      Dir.exists?(tester.sandbox_directory).should be_true
      tester.cleanup!
      Dir.exists?(tester.sandbox_directory).should be_false
    end
  end
end
