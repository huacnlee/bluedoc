# frozen_string_literal: true

module BlueDoc
  module GraphQL
    class IntegrationTest < ActiveSupport::TestCase
      attr_accessor :response

      def execute(query_string)
        @response = BlueDocSchema.execute(query_string, context: context)
        assert_not_nil @response
      end

      def context
        { current_user: @current_user }
      end

      def response_data
        unless response_errors.blank?
          raise "Expect to get response_data by there has errors\n\n  #{response_errors}"
        end

        @response["data"]
      end

      def response_errors
        @response["errors"]
      end

      def sign_in(user)
        @current_user = user
      end

      def sign_out
        @current_user = nil
      end

      def assert_error_with(message)
        found = false
        errors = response_errors || []
        errors.each do |error|
          if error["message"] == message
            found = true
            break
          end
        end

        assert_equal true, found, <<~MSG
        expected: #{errors.inspect}
        include:  #{message}
        MSG
      end

      def assert_unauthorized
        assert_error_with("You are not authorized to access this page.")
      end
    end
  end
end
