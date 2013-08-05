module Bait
  module SimpleCovSupport
    def coverage_dir
      File.join(clone_path, 'coverage')
    end

    def simplecov_html_path
      File.join(coverage_dir, "index.html")
    end

    def check_for_simplecov
      if File.exists? simplecov_html_path
        self.simplecov = true
        convert_paths
        self.broadcast :simplecov, 'supported'
        self.save
      end
    end

    def convert_paths
      buffer = ""
      File.open(simplecov_html_path, "r") do |file|
        buffer = file.read.gsub("./assets", "/build/#{self.id}/coverage/assets")
      end
      File.open(simplecov_html_path, "w") do |file|
        file.write buffer
      end
    end
  end
end
