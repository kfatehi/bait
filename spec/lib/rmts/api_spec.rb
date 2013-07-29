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

    describe "POST /" do
      it "creates a build" do
        post '/', payload: github_json
        Rmts::Build.last.name.should eq "github"
      end
    end
  end
end
