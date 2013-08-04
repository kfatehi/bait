require 'spec_helper'
require 'bait/api'

describe Bait::Api do
  let(:app) { Bait::Api }
  subject { last_response }

  let (:build) { Bait::Build.last }

  describe "github post-receive hook" do
    let(:github_json) do
      <<-GITHUB_JSON
        { 
          "before": "5aef35982fb2d34e9d9d4502f6ede1072793222d",
          "repository": {
            "url": "http://github.com/keyvanfatehi/bait",
            "name": "github",
            "owner": {
              "email": "chris@ozmm.org",
              "name": "defunkt" 
            }
          },
          "commits": {
            "41a212ee83ca127e3c8cf465891ab7216a705f59": {
              "url": "http://github.com/defunkt/github/commit/41a212ee83ca127e3c8cf465891ab7216a705f59",
              "author": {
                "email": "chris@ozmm.org",
                "name": "Chris Wanstrath" 
              },
              "message": "okay i give in",
              "timestamp": "2008-02-15T14:57:17-08:00" 
            },
            "de8251ff97ee194a289832576287d6f8ad74e3d0": {
              "url": "http://github.com/defunkt/github/commit/de8251ff97ee194a289832576287d6f8ad74e3d0",
              "author": {
                "email": "chris@ozmm.org",
                "name": "Chris Wanstrath" 
              },
              "message": "update pricing a tad",
              "timestamp": "2008-02-15T14:36:34-08:00" 
            }
          },
          "after": "de8251ff97ee194a289832576287d6f8ad74e3d0",
          "ref": "refs/heads/master" 
        }
      GITHUB_JSON
    end

    describe "POST /" do
      before do
        post '/', payload: github_json
      end

      it { should be_ok }

      it "creates a build" do
        build.name.should eq "github"
        build.owner_name.should eq "defunkt"
        build.owner_email.should eq "chris@ozmm.org"
        build.ref.should eq "refs/heads/master"
      end

      specify { build.should be_queued }
    end
  end

  describe "GET /" do
    before { get '/' }
    it { should be_redirect }
  end

  describe "GET /build"  do
    before do 
      Bait::Build.create(name: "quickfox", clone_url:'...')
      Bait::Build.create(name: "slowsloth", clone_url:'...')
      get '/build'
    end

    it { should be_ok }

    it "shows the builds" do
      subject.body.should match /quickfox/
      subject.body.should match /slowsloth/
    end
  end

  describe "POST /build/create" do
    let(:test_url){ repo_path }
    before do
      post '/build/create', {clone_url:test_url}
    end
    specify { build.clone_url.should eq test_url }
    specify { build.name.should match(/^bait/) }
    specify { build.should be_queued }
  end

  describe "GET /build/:id/remove" do
    before do
      @build = Bait::Build.create(name: "quickfox", clone_url:'...')
      @sandbox = @build.sandbox_directory
      get "/build/#{@build.id}/remove"
    end
    it "removes the build from store and its files from the filesystem" do
      expect{@build.reload}.to raise_error Toy::NotFound
      Bait::Build.ids.should be_empty
      Pathname.new(@sandbox).should_not exist
    end
    it { should be_redirect }
  end

  describe "GET /build/:id/retest" do
    before do
      @build = Bait::Build.create(name: "quickfox", clone_url:'...')
      @build.tested = true
      @build.output = "bla bla old output"
      @build.save
      get "/build/#{@build.id}/retest"
    end
    it "queues the build for retesting" do
      @build.reload.should be_queued
    end
    it "clears the previous output" do
      @build.reload.output.should be_blank
    end
    it { should be_redirect }
  end

  describe "GET /build/:id/events" do
    let(:build) { Bait::Build.create(name: "bait", clone_url:repo_path) }
    let (:connect!) { get "/build/#{build.id}/events" }
    it "adds a subscriber to the build" do
      Bait.should_receive(:add_subscriber).with(build.id, anything()).once
      connect!
    end
    it "provides an event stream connection" do
      connect!
      last_response.content_type.should match(/text\/event-stream/)
    end
  end
end
