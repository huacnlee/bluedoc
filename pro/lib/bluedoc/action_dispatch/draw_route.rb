# frozen_string_literal: true

module Pro
  module BlueDoc
    module ActionDispatch
      module DrawRoute
        def draw(routes_name)
          route = super | draw_route(Rails.root.join("pro/config/routes/#{routes_name}.rb"))

          route || raise("Cannot find Pro #{routes_name}")
        end
      end
    end
  end
end

BlueDoc::ActionDispatch::DrawRoute.prepend(Pro::BlueDoc::ActionDispatch::DrawRoute)
