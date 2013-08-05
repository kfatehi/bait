module Bait
  module SimpleCovSupport
    def simplecov_html_path
      File.join(clone_path, "coverage", "index.html")
    end

    def check_for_simplecov
      if File.exists? simplecov_html_path
        self.simplecov = true
        self.save
      end
    end
  end
end
