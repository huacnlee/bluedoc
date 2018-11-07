module Activities
  class Base
    attr_accessor :actor

    delegate :id, to: :actor, prefix: true, allow_nil: true

    def initialize
      @actor = Current.user
    end
  end
end