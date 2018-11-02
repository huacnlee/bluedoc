json.extract! repository, :id, :slug, :name, :description, :user_id, :created_at, :updated_at
json.url repository_url(repository, format: :json)
