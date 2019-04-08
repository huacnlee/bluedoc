# frozen_string_literal: true

module Types
  class DocType < BaseType
    graphql_name "Doc"

    field :slug, String, null: false, description: "Document slug"
    field :path, String, null: false, method: :to_path, description: "Full path of this document"
    field :title, String, null: true
    field :last_editor, UserType, null: true, description: "Last edit user"
    field :body, String, method: :body_plain, null: true, description: "Markdown body"
    field :body_sml, String, method: :body_sml_plain, null: true, description: "SML format body, this is main content"
    field :body_html, String, method: :body_html, null: true, description: "HTML result of body"
    field :toc, RepositoryTocType, null: false, description: "Toc prefernces"
  end
end
