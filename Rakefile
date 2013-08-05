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
        file.puts compile assets[:paths]
      end
    end
  end
end
