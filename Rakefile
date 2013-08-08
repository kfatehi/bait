ENV['RACK_ENV'] = "development"

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :pry do
  require 'pry'; binding.pry
end

def git_master?
  `git branch | grep '* master'`
  $?.exitstatus == 0
end

APP_FILE = "lib/bait/api.rb"
require 'sinatra/asset_snack/rake'
namespace(:assets) { task :precompile => 'assetsnack:build' }

namespace :git do
  task :dirty do
    if `git status --porcelain`.match(/M /)
      puts "Dirty working tree! Commit first before building!"
      exit
    end
  end
end

namespace :gem do
  task :build do
    `bundle install`
    Rake::Task['git:dirty'].invoke
    if !git_master?
      puts "I'll only build the gem on the master branch"
    else
      puts "On master branch, running test suite; please wait."
      `rspec spec`
      if $?.exitstatus != 0
        puts "Uhh.. you have failing specs -- not building the gem"
      else
        puts "Specs pass. you're ready"
        Rake::Task['assets:precompile'].invoke
        Rake::Task['git:dirty'].invoke
        puts `gem build bait.gemspec`
        puts "Done! You can gem push that now"
      end
    end
  end

  task :push => :build do
    require "bait/version"
    gem = "bait-#{Bait::VERSION}.gem"
    if File.exists?(gem)
      begin
        puts "Press any key to push to Rubygems"
        STDIN.gets
        puts "Pushing gem to rubygems"
        puts `gem push #{gem}`
      rescue Interrupt
        puts "ancelled"
      end
    else
      puts "File not found #{gem}"
    end
  end
end
