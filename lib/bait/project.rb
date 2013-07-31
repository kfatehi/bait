module Bait
  class Project
    def initialize root_path
      unless Dir.exists? root_path
        raise "Expected a valid directory"
      end
      @path = Pathname.new(root_path)
    end

    def glob pattern
      Dir.glob @path.join("**/#{pattern}")
    end

    def ordered_dependencies file_pattern, klass
      orderer = klass.new(glob(file_pattern), self)
      orderer.start
      orderer.order
    end
  end
end
