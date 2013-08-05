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

  describe "hooks" do
    describe "after_create hook" do
      it "broadcasts its creation" do
        Bait.should_receive(:broadcast).with(:global, :new_build, kind_of(Bait::Build))
        build
      end
    end

    describe "after_destroy hook" do
      before { build }
      it "broadcasts its removal" do
        Bait.should_receive(:broadcast).with(:build, :remove, build.id)
        build.destroy
      end
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

  describe "#sandbox_directory" do
    it "is beneath Bait storage directory" do
      build.sandbox_directory.should match Bait.storage_dir
    end
  end

  describe "#cloned?" do
    specify { build.should_not be_cloned }
  end

  describe "#clone!" do
    context 'valid clone url' do
      before { build.clone_url = repo_path ; build.clone! }
      specify { build.output.should_not match /Failed to clone/ }
      specify { build.should be_cloned }
    end
    context "invalid clone url" do
      before { build.clone_url = "invalid" ; build.clone! }
      specify { build.output.should match /Failed to clone/ }
      specify { build.should_not be_cloned }
    end
  end

  describe "cleanup!" do
    before do
      build.clone!
    end
    it "removes the entire sandbox" do
      Dir.exists?(build.sandbox_directory).should be_true
      build.cleanup!
      Dir.exists?(build.sandbox_directory).should be_false
    end
  end

  describe "simplecov support" do
    context 'has simplecov files' do
      before do
        FileUtils.mkdir_p File.dirname build.simplecov_html_path
        FileUtils.touch build.simplecov_html_path
      end
      it "sends an event that it discovered simplecov" do
        Bait.should_receive(:broadcast).with(:build, :simplecov, build.id, 'supported')
        build.check_for_simplecov
      end
      it "sets the simplecov flag to true" do
        build.reload.simplecov.should be_false
        build.check_for_simplecov
        build.reload.simplecov.should be_true
      end
    end

    context 'has no simplecov files' do
      before { build }
      it "does not broadcast a simplecov supported message" do
        Bait.should_not_receive(:broadcast).with(:build, :simplecov, build.id, 'supported')
        build.check_for_simplecov
      end
      it "does not set the simplecov flag to true" do
        build.check_for_simplecov
        build.reload.simplecov.should be_false
      end
    end
  end
end
