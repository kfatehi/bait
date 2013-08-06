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

        def compile!
          Module.new do
            require 'bait/api'
            require 'sinatra/asset_snack'
            extend Sinatra::AssetSnack::InstanceMethods
            Sinatra::AssetSnack.assets.each do |assets|
              path = File.join(Bait.public, assets[:route])
              File.open(path, 'w') do |file|
                file.write compile(assets[:paths])[:body]
              end
            end
          end
        end
      end.new
    end
  end
end
