module Types
  class Query
    field :hello, String, null: true, description: "Simple test API"

    def hello
      message = "Hello"
      if current_user
        message += ", #{current_user.name}"
      end
      message
    end
  end
end