module Pro
  module BookLab
    module FeatureHelper
      extend ActiveSupport::Concern

      included do
        helper_method :check_feature!, :allow_feature?, :feature_for
      end

      def check_feature!(name)
        raise "Feature not available!" unless License.allow_feature?(name)
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

ActionController::Base.send(:include, Pro::BookLab::FeatureHelper)