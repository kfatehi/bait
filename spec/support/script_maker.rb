module Bait
  module SpecHelpers
    module ScriptMaker
      def write_script_with_status script, status
        File.open(script, "w") do |f|
          f.puts "#!/usr/bin/env bash"
          f.puts "echo this is a test script"
          f.puts "exit #{status.to_i}"
        end
        File.chmod(0755, script)
      end
    end
  end
end
