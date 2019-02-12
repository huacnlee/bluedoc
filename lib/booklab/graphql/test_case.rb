module BookLab
  module GraphQL
    class TestCase < ActiveSupport::TestCase
      attr_accessor :response

      def execute(query_string, context: {})
        @response = BookLabSchema.execute(query_string, context: context)
        assert_nil @response["errors"]
      end

      def response_data
        @response["data"]
      end
    end
  end
end
