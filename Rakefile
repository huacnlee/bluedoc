# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative "config/application"

Rails.application.load_tasks

namespace :elasticsearch do
  desc "Remove all exists indexes in ElasticSearch"
  task clear: :environment do
    puts "Remove elasticsearch..."
    %w(Doc Repository Group User).each do |model_name|
      model_name.constantize
    end
    puts Elasticsearch::Model::Registry.all.collect(&:index_name).join(", ").indent(4)

    Elasticsearch::Model::Registry.all.each do |klass|
      puts "Remove index: #{klass.index_name}".indent(4)
      Elasticsearch::Model.client.indices.delete index: klass.index_name
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
    end
  end
end