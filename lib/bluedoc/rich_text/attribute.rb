# frozen_string_literal: true

module BlueDoc
  module RichText
    # Fork ActionText has_rich_text method from:
    # https://github.com/rails/actiontext/blob/18974137be2c4027dfcf430668edd712e7ec011b/lib/action_text/attribute.rb
    module Attribute
      extend ActiveSupport::Concern

      class_methods do
        def has_rich_text(name)
          class_eval <<-CODE, __FILE__, __LINE__ + 1
            def #{name}
              self.rich_text_#{name} ||= ::RichText.new(name: "#{name}", record: self)
            end

            def #{name}=(body)
              self.#{name}.body = body
            end
          CODE

          has_one :"rich_text_#{name}", -> { where(name: name) }, class_name: "::RichText", as: :record, inverse_of: :record
          scope :"with_rich_text_#{name}", -> { includes("rich_text_#{name}") }

          after_save do
            public_send(name).save if public_send(name).changed?
          end
        end
      end
    end
  end
end
