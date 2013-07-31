require 'bait/objective_c/project'

module Bait
  module ObjectiveC
    class DependencyOrderer
      attr_accessor :errors, :order, :queue, :project
      def initialize path_array, project
        @project = project
        @queue = path_array
        @order = []
        @errors = []
      end

      def examine_file path
        return unless path && File.exists?(path)
        if @order.include? path
          return
        end
        imports_within(path).each do |name|
          examine_file @project.glob(name).first
        end
        @order << path
      end

      def imports_within path
        imports = []
        File.open(path, 'r') do |f|
          f.each_line do |line|
            if matches = line.match(/^#import "(.*)"/)
              imports << matches[1]
            end
          end
        end
      rescue => ex
        @errors << ex
      ensure
        return imports
      end

      def start
        @queue.each do |path|
          examine_file path
        end
      end
    end
  end
end

