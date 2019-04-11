# frozen_string_literal: true

# /admin
authenticate :user, ->(u) { u.admin? } do
  mount Sidekiq::Web, at: "/admin/sidekiq"
  mount ExceptionTrack::Engine, at: "/admin/exception-track"
  mount PgHero::Engine, at: "/admin/pghero"
end

namespace :admin do
  root to: "dashboards#show"
  resource :dashboard do
    collection do
      post :reindex
    end
  end
  resource :settings do
    collection do
      post :test_mail
    end
  end
  resources :groups
  resources :users
  resources :repositories
  resources :docs
  resources :comments
  resources :shares
  resources :issues
  resources :notes
end
