module Bait
  module BuildHelper
    def queued?
      self.reload.status == "queued"
    end

    def passed?
      self.reload.status == "passed"
    end

    def clone_path
      File.join(sandbox_directory, self.name)
    end

    def bait_dir
      File.join(clone_path, ".bait")
    end

    def script name
      File.join(bait_dir, name)
    end

    def cloned?
      Dir.exists? File.join(clone_path, ".git/")
    end

    def cleanup!
      FileUtils.rm_rf(sandbox_directory) if Dir.exists?(sandbox_directory)
    end

    def sandbox_directory
      File.join Bait.storage_dir, "tester", self.name, self.id
    end
  end
end

