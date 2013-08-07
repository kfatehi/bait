module Bait
  module Assets
    def assets
      Class.new do
        def missing?
          !Bait.public.join('js', 'application.js').exist? &&
          !Bait.public.join('css', 'application.css').exist?
        end

        def remove!
          FileUtils.rm(Bait.public.join('js', 'application.js')) rescue nil
          FileUtils.rm(Bait.public.join('css', 'application.css')) rescue nil
        end

        def dynamic?
          Bait.env != "production"
        end
      end.new
    end
  end
end
