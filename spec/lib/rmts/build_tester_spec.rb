require 'spec_helper'
require 'rmts/build_tester'

describe Rmts::BuildTester do
  let(:repo_path) do
    path = File.join(File.dirname(__FILE__), '..', '..', '..')
    File.expand_path(path)
  end
  let(:build) { Rmts::Build.create(name: "rmts", clone_url:repo_path) }
  subject { build.tester }

  describe "#sandbox_directory" do
    it "creates a directory on disk" do
      Dir.exists?(subject.sandbox_directory).should be_true
    end

    it "is beneath Rmts storage directory" do
      subject.sandbox_directory.should match Rmts.storage_dir
    end
  end

  describe "#cloned?" do
    it { should_not be_cloned }
  end

  describe "#clone!" do
    before { subject.clone! }
    it { should be_cloned }
  end

  describe "#test!" do
    before do
      subject.clone!
      subject.test!
    end
    context "successful" do
      specify { subject.passed.should be_true }
    end
    context 'failure' do
      specify { subject.passed.should be_false }
    end
  end
end
