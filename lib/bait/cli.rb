require 'bait'

module Bait
  module CLI
    USAGE = %{usage:
      * bait .................... alias for bait server
      * bait server ............. start the bait server
      * bait init ............... setup current directory as a bait project
      * bait test <name> ........ execute a script in .bait/*}

    ##
    # Start the server
    def self.server username=false, password=false
      puts "** Bait/#{Bait::VERSION} booting up in #{Bait.env} environment"
      if Bait.env == "production" && Bait.assets.missing?
        Bait.assets.compile!
      end
      require 'pry'
      binding.pry
      if username && password
        $HTTP_AUTH = {username:username, password:password}
      end 
      require 'bait/api'
      Bait::Api.run!
    end
    
    ##
    # Create .bait/ and config.yml and example .bait/test.sh
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
        puts "Created executable script #{script}."
        name = File.basename(script)
        config_file = File.join(bait_dir, 'config.yml')
        File.open(config_file, "w") do |f|
          f.puts "---"
          f.puts "- #{name}"
        end
        puts "Setup one phase in #{config_file} pointing to #{name}."
      end
    end

    ##
    # Run a defined phase
    def self.test name=nil
      dir = Dir.pwd, ".bait"
      config_file = File.join(dir, "config.yml")
      if File.exists? config_file
        require 'yaml'
        scripts = YAML.load_file(config_file)
        if scripts.empty?
          puts "Define your scripts in #{config_file}"
          exit 1
        end
        runscript = proc do |script, quit|
          puts "Running #{script}"
          system script
          status = $?.exitstatus
          puts "Exited with status #{status}"
          exit status if quit
        end
        if name
          script = File.join(dir, name)
          scripts.select do |a|
            if a == name
              unless File.executable? script
                puts "Missing executable #{script}"
                exit 1
              else
                runscript.call(script)
              end
            end
          end
          puts "Script #{script} not defined in #{config_file}"
          exit 1
        else
          puts "Running all defined in #{config_file}"
          scripts.each do |name|
            script = File.join(dir, name)
            runscript.call(script, false)
          end
        end
      else
        puts "Project did not have configuration file #{config_file}"
        exit 1
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
