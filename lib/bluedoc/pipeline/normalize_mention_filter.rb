# frozen_string_literal: true

module BlueDoc
  class Pipeline
    class NormalizeMentionFilter < ::HTML::Pipeline::TextFilter
      PREFIX_REGEXP = %r{(^|[^#{BlueDoc::Slug::FORMAT}!#/\$%&*@＠])}
      USER_REGEXP   = /#{PREFIX_REGEXP}@([#{BlueDoc::Slug::FORMAT}]{1,30})/io

      def call
        users = []
        # Makesure clone a new value, not change original value
        text = @text.clone.dup
        text.gsub!(USER_REGEXP) do
          prefix = Regexp.last_match(1)
          user   = Regexp.last_match(2)
          users.push(user)
          "#{prefix}@user#{users.size}"
        end
        result[:normalize_mentions] = users
        text
      end
    end
  end
end
