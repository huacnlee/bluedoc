# frozen_string_literal: true

module Searchable
  extend ActiveSupport::Concern

  included do
    after_commit :reindex!, on: [:create, :update]
    after_commit :destroy_depend_search_texts, on: [:destroy]
  end

  def reindex!
    SearchText.reindex(self)
  end

  private

    def destroy_depend_search_texts
      SearchText.destroy_index(self)
    end
end