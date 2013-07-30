require 'spec_helper'
require 'rmts/build_tester'

describe Rmts::BuildTester do
  let(:build) { Rmts::Build.create(name: "testable") }
  let(:tester) { build.tester }
  let(:path) { tester.sandbox_directory }

  describe "sandbox directory" do
    it "exists" do
      Dir.exists?(path).should be_true
    end
    it "is beneath Rmts storage directory" do
      path.should match Rmts.storage_dir
    end
  end

  describe "#clone" do

  end
end
