require 'bait/project'

describe Bait::Project do
  it "requires a valid root path" do
    expect { Bait::Project.new('fawfewa') }.to raise_error
    expect { Bait::Project.new('/') }.not_to raise_error
  end
end
