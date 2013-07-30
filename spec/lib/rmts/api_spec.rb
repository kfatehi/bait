require 'spec_helper'
require 'rmts/api'
require 'rmts/build'

describe "Sinatra App" do
  let(:app) { Rmts::Api }
  subject { last_response }

  describe "github post-receive hook" do
    let(:github_json) do
      <<-GITHUB_JSON
        { 
          "before": "5aef35982fb2d34e9d9d4502f6ede1072793222d",
          "repository": {
            "url": "http://github.com/defunkt/github",
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

    let (:build) { Rmts::Build.last }

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

      it "will be tested later based on a flag" do
        build.should_not be_tested
      end
    end

    describe "GET /" do
      before { get '/' }
      it { should be_redirect }
    end

    describe "GET /build" do
      before do
        Rmts::Build.create(name: "quickfox", clone_url:'...')
        Rmts::Build.create(name: "slowsloth", clone_url:'...')
        get '/build'
      end

      it { should be_ok }

      it "shows the builds" do
        subject.body.should match /quickfox/
        subject.body.should match /slowsloth/
      end
    end

    describe "POST /build/create" do
      let(:test_url){ "http://github.com/defunkt/github" }
      it "can create a build manually" do
        post '/build/create', {clone_url:test_url}
        build.clone_url.should eq test_url
      end
    end

    describe "GET /build/remove/#" do
      before do
        @build = Rmts::Build.create(name: "quickfox", clone_url:'...')
      end
      it "removes builds from the store" do
        get "/build/remove/#{@build.id}"
        expect{@build.reload}.to raise_error Toy::NotFound
      end
    end
  end
end
