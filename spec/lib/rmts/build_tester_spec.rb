require 'spec_helper'
require 'rmts/build_tester'

describe Rmts::BuildTester do
  let(:build) { Rmts::Build.create(name: "testable") }
  let(:tester) { build.tester }

  describe "#sandbox_directory" do
    it "creates a directory on disk" do
      Dir.exists?(tester.sandbox_directory).should be_true
    end

    it "is beneath Rmts storage directory" do
      tester.sandbox_directory.should match Rmts.storage_dir
    end
  end

  describe "#clone!" do
    it "clones the project into the sandbox" do
      tester.clone!
      tester.sandbox_contents.should have(1).item
      gitdir = File.join(tester.sandbox_contents, ".git/")
      Dir.exists?(gitdir).should be_true
    end
  end
end
