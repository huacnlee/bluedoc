# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphql/explorer", graphql_path: "/graphql"
  end
  post "/graphql", to: "graphql#execute"
  get "/health", to: proc { [200, {}, ["ok"]] }

  devise_for :users, path: "account", controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords"
  }
  get "/account/sign_in/ldap" => "users/ldaps#new", as: :new_ldap_user_session

  draw :admin

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
      get :docs
      get :repositories
      get :groups
      get :stars
      get :explore
    end
  end
  # GET /new
  get "new", to: "repositories#new", as: :new_repository
  # GET /new/import
  get "new/import", to: "repositories#import", as: :import_repository
  resource :autocomplete do
    collection do
      get :users
    end
  end

  # GET /groups/new, POST /groups
  resources :groups, only: %i[new create] do
    member do
      get :search
    end
    resources :group_members, as: :members, path: :members
    resource :group_settings, as: :settings, path: :settings
  end
  # GET /notes/new, POST /notes
  resources :notes, only: %i[new create]
  resources :versions
  resource :search do
    collection do
      get :docs
      get :repositories
      get :groups
      get :users
      get :notes
      get :issues
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
  resources :shares

  # NOTE! Keep :profile routes bottom of routes.rb
  resources :repositories, only: %i(index create)
  resources :users, id: /[#{BlueDoc::Slug::FORMAT}]*/, path: "", as: "users" do
    member do
      post :follow
      delete :unfollow
    end
    resources :notes, only: %i(index create edit show update destroy) do
      member do
        get :raw
        get :versions
        patch :revert
        post :action
        delete :action
        # PRO-begin
        get :readers
        # PRO-end
        post :pdf
      end
    end
    resources :repositories, path: "", as: "repositories", only: %i(show update destroy) do
      resource :services do
        collection do
          get :jira_issues
        end
      end
      member do
        get :docs, path: "docs/list"
        get :search, path: "docs/search"
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
          post :export
          get :export
          get :collaborators
          post :collaborators
          post :collaborator
          delete :collaborator
          post :retry_import
          get :integrations
          post :jira
        end
      end
      resources :docs, only: %i(new create)
      resources :labels, path: "issues/labels"
      resources :issues do
        collection do
          get :closed
        end
        member do
          post :assignees
          post :labels
        end
      end
      resources :docs, path: "", only: %i(show edit update destroy) do
        member do
          get :raw
          post :pdf
          get :lock
          post :lock
          post :action
          delete :action
          get :versions
          patch :revert
          patch :abort_draft
          post :share
          # PRO-begin
          get :readers
          # PRO-end
        end
      end
    end
  end
end
