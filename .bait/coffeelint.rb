#!/usr/bin/env ruby
#!/usr/bin/env ruby

#
# Use:
#
# => cfl
# => cfl all
# => cfl last
# => cfl last 3
#

ARGV.push "all"

class LintRunner
  attr_reader :files

  def initialize
    # Find all coffee files, sort by last modified time
    @files = Dir['**/*.coffee'].sort_by { |f| File.mtime(f) }
    @printed = 0
  end

  def lint(index)
    if (@printed > 0)
      puts "----------------------------------------------------------------------------\n\n"
    end

    file = @files[index]
    system "coffeelint #{file}"
    @printed = @printed + 1
  end
end

runner = LintRunner.new

# Lint based on args
if ARGV.length > 0
  if ARGV[0] == 'last'
    if ARGV[1]
      ARGV[1].to_i.times {|i| runner.lint i }
    else 
      runner.lint 0
    end
  elsif ARGV[0] == 'all'
    runner.files.length.times {|i| runner.lint i }
  elsif ARGV[0] == 'list'
    runner.files.each {|f| puts "  #{f}" }
  end
else
  runner.lint 0
end
