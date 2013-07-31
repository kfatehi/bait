require 'bait/objective_c/project'

describe Bait::ObjectiveC::Project do
  subject { Bait::ObjectiveC::Project.new "/" }
  it { should respond_to :h_files }
  it { should respond_to :m_files }
end

