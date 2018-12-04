# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :users, path: "account", controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    sessions: "users/sessions",
    registrations: "users/registrations",
  }

  # /admin
  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web, at: "/admin/sidekiq"
    mount ExceptionTrack::Engine, at: "/admin/exception-track"
  end

  namespace :admin do
    root to: "dashboards#show"
    resource :dashboard do
      collection do
        post :reindex
      end
    end
    resource :settings
    resources :groups
    resources :users
    resources :repositories
    resources :docs
  end

  # short attachment url
  get "/uploads/:id" => "blobs#show", as: :upload

  resources :notifications do
    collection do
      get :all
      post :read
      delete :clean
    end
  end

  resource :account_settings, as: :account_settings, path: "account/settings" do
    collection do
      get :account
    end
  end

  root to: "dashboards#index"
  resource :dashboard do
    member do
      get :activities
      get :groups
      get :repositories
      get :docs
      get :stars
      get :watches
    end
  end
  get "new", to: "repositories#new", as: :new_repository
  resource :autocomplete do
    collection do
      get :users
    end
  end

  resources :groups do
    member do
      get :search
    end
    resources :group_members, as: :members, path: :members
    resource :group_settings, as: :settings, path: :settings
  end
  resources :versions
  resource :search do
    collection do
      get :docs
      get :repositories
      get :groups
      get :users
    end
  end
  resources :comments do
    member do
      get :reply
      get :in_reply
    end
    collection do
      post :watch
      delete :watch
    end
  end
  resource :reactions, path: "user/reactions"
  resources :shares

  # NOTE! Keep :profile routes bottom of routes.rb
  resources :repositories, only: %i(index create)
  resources :users, id: /[#{BookLab::Slug::FORMAT}]*/, path: "", as: "users" do
    member do
      post :follow
      delete :unfollow
    end

    resources :repositories, path: "", as: "repositories", only: %i(show update destroy) do
      member do
        get :docs, path: "docs/list"
        get :search, path: "docs/search"
        get :toc, path: "toc/edit"
        patch :toc, path: "toc/edit"
        post :action
        delete :action
      end
      resource :repository_settings, path: "settings", as: :settings do
        collection do
          get :show, path: "profile"
          put :update, path: "profile"
          patch :update, path: "profile"
          delete :destroy, path: "profile"
          get :advanced
          patch :transfer
          get :docs
          post :docs
        end
      end

      resources :docs, only: %i(new create)
      resources :docs, path: "", only: %i(show edit update destroy) do
        member do
          get :raw
          get :lock
          post :lock
          post :action
          delete :action
          get :versions
          patch :revert
          post :share
        end
      end
    end
  end
end
