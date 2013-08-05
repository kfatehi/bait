ENV['RACK_ENV'] = "development"

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :pry do
  require 'pry'; binding.pry
end

namespace :assets do
  task :precompile do
    public = File.join File.dirname(__FILE__), %w(lib bait public)
    require 'bait/api'
    include Sinatra::AssetSnack::InstanceMethods
    Sinatra::AssetSnack.assets.each do |assets|
      compiled_path = File.join public, assets[:route]
      puts "compiling #{compiled_path}"
      File.open(compiled_path, 'w') do |file|
        response = compile assets[:paths]
        file.write response[:body]
      end
    end
  end
end


def git_master?
  `git branch | grep '* master'`
  $?.exitstatus == 0
end

def git_dirty?
  `git status --porcelain`.match(/^\sM/)
end

namespace :gem do
  task :build do
    `bundle install`
    if !git_master?
      puts "I'll only build the gem on the master branch"
    else
      puts "On master branch"
      `rspec spec`
      if $?.exitstatus != 0
        puts "Uhh.. you have failing specs -- not building the gem"
      else
        puts "Specs pass. you're ready"
        Rake::Task['assets:precompile'].invoke
        if git_dirty?
          puts "Dirty working tree! Commit first before building!"
          exit
        end
        puts `gem build bait.gemspec`
        puts "Done! You can gem push that now"
      end
    end
  end

  task :push => :build do
    require "bait/version"
    gem = "bait-#{Bait::VERSION}.gem"
    if File.exists?(gem)
      puts "Pushing gem to rubygems"
      puts `gem push #{gem}`
    else
      puts "File not found #{gem}"
    end
  end
end
