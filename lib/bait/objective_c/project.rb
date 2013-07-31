require 'bait/project'
require 'bait/objective_c/dependency_orderer'

module Bait
  module ObjectiveC
    class Project < Bait::Project
      def h_files
        @h_files ||= ordered_dependencies '*.h', ObjectiveC::DependencyOrderer
      end

      def m_files
        @m_files ||= ordered_dependencies '*.m', ObjectiveC::DependencyOrderer
      end
    end
  end
end

