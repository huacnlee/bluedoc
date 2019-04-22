class InlineComment < ApplicationRecord
  class << self
    def find_or_create_by_subject_nid(subject, nid)
      create_or_find_by!(subject: subject, nid: nid)
    end
  end
end