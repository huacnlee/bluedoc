module BookLab
  module ActionDispatch
    module DrawRoute
      def draw(routes_name)
        route = draw_route(Rails.root.join("config/routes/#{routes_name}.rb"))

        route || raise("Cannot find #{routes_name}")
      end

      private

        def draw_route(path)
          return false unless File.exist?(path)

          instance_eval(File.read(path))
          true
        end
    end
  end
end