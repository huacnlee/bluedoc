class Group
  include Searchable
  include Elasticsearch::Model

  index_name { "#{Rails.env}-groups" }
  document_type name.underscore
end