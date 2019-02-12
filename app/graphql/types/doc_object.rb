module Types
  class DocObject < BaseObject
    graphql_name "Doc"

    field :slug, String, null: false, description: "Document slug"
    field :path, String, null: false, method: :full_slug, description: "Full path of this document"
    field :title, String, null: true
    field :body, String, method: :body_plain, null: true, description: "Markdown body"
    field :body_sml, String, method: :body_sml_plain, null: true, description: "SML format body, this is main content"
    field :body_html, String, method: :body_html, null: true, description: "HTML result of body"
  end
end