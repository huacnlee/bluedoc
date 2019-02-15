# frozen_string_literal: true

module Pro
  module BlueDoc
    module FeatureHelper
      extend ActiveSupport::Concern

      included do
        helper_method :check_feature!, :allow_feature?, :feature_for

        rescue_from FeatureNotAvailableError do |exception|
          respond_to do |format|
            format.json { head :not_implemented }
            format.html { render plain: "Feature not available!", status: :not_implemented }
          end
        end
      end

      def check_feature!(name)
        return if allow_feature?(name)
        raise ::BlueDoc::FeatureNotAvailableError.new("Feature not available!")
      end

      def allow_feature?(name)
        License.allow_feature?(name)
      end

      def feature_for(name, &block)
        return "" unless allow_feature?(name)
        block.call
      end
    end
  end
end

ActionController::Base.send(:include, Pro::BlueDoc::FeatureHelper)
