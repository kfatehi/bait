require 'bait'

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
      puts "** Bait/#{Bait::VERSION} booting up in #{Bait.env} environment"
      if Bait.env == "production" && Bait.assets.missing?
        Bait.assets.compile!
      end
      require 'bait/api'
      Bait::Api.run!
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
        system script
        status = $?.exitstatus
        puts "exited with status #{status}"
        exit status
      end
    end

    ##
    # Create .bait/ and list.yml and example .bait/test.sh
    # I do not seek to read your mind, instead I'd prefer that 
    # you contribute Scripts for different Contexts/Technologies
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
          f.puts "echo 'Running tests. Oh no tests.'"
          f.puts "echo 0 examples, 1 failure"
          f.puts "exit 1"
        end
        File.chmod(0744, script)
        puts "Created executable script #{script}. Test it \
          with bait test or commit and run the server and clone this repo."
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
