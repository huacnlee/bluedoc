# frozen_string_literal: true

module BookLab
  class Pipeline
    class NormalizeMentionFilter < ::HTML::Pipeline::TextFilter
      PREFIX_REGEXP = %r{(^|[^#{BookLab::Slug::FORMAT}!#/\$%&*@＠])}
      USER_REGEXP   = /#{PREFIX_REGEXP}@([#{BookLab::Slug::FORMAT}]{1,30})/io

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
