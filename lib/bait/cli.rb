module Bait
  module CLI
    USAGE = %{usage:
    * bait .................... alias for bait server
    * bait server ............. start the bait server
    * bait init ............... setup current directory as a bait project
    * bait test ............... simulate this repo being tested with bait}

    ##
    # Start the server
    def self.server
      puts "== Bait/#{Bait::VERSION} booting up..."
      require 'bait/api'
      Bait::Api.run!
    end

    ##
    # Start the Ncurses GUI
    def self.ncurses
      require 'bait/gui/init'
      Bait::GUI.init!
    end

    ##
    # Run the test suite script in .bait/test.sh
    def self.test
      script = File.join(Dir.pwd, ".bait", "test.sh")
      unless File.executable? script
        puts "Project did not have executable #{script}"
        puts "Run 'bait init' to create it"
        exit 1
      else
        system(script)
      end
    end

    ##
    # Create .bait/ and executable .bait/test.sh
    def self.init
      bait_dir = File.join(Dir.pwd, ".bait")
      if File.directory? bait_dir
        puts "Directory already exists: #{bait_dir}"
      else
        script = File.join(bait_dir, 'test.sh')
        FileUtils.mkdir bait_dir
        puts "Created #{bait_dir}"
        File.open(script, 'w') do |f|
          f.puts "#!/bin/bash"
          f.puts "echo edit me"
        end
        File.chmod(0744, script)
        puts "Created executable script #{script}"
      end
    end

    def self.method_missing method
      unless method.to_sym == :help
        puts "Command not found: #{method}"
      end
      puts USAGE
    end
  end
end
