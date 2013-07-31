require 'bait/objective_c/dependency_orderer'

describe Bait::ObjectiveC::DependencyOrderer do
  it "initializes with a path array and a Bait::Project" do
    project = Bait::ObjectiveC::Project.new File.dirname(__FILE__)
    Bait::ObjectiveC::DependencyOrderer.new [], project
  end
end
