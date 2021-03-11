# frozen_string_literal: true

module SoftDelete
  extend ActiveSupport::Concern

  included do
    default_scope -> { where(deleted_at: nil) }

    # PRO-begin
    define_callbacks :soft_delete, :restore
    alias_method :destroy!, :destroy
    # PRO-end

    after_destroy :expire_second_level_cache
  end

  def deleted?
    deleted_at.present?
  end

  # Permanently destroy record
  def permanent_destroy
    self.class.transaction do
      run_callbacks(:soft_delete) do
        run_callbacks(:destroy) do
          if persisted?
            delete
          end

          @destroyed = true
        end
      end
    end
    freeze
  end

  # PRO-begin
  def destroy
    attrs = {deleted_at: Time.now.utc, updated_at: Time.now.utc}
    attrs = soft_delete_destroy_attributes if defined? soft_delete_destroy_attributes

    self.class.transaction do
      run_callbacks(:soft_delete) do
        run_callbacks(:destroy) do
          if persisted?
            update_columns(attrs)
          end

          @destroyed = true
        end
      end
    end
    freeze
  end

  def restore
    @destroyed = false
    attrs = {deleted_at: nil, updated_at: Time.now.utc}
    attrs = soft_delete_restore_attributes if defined? soft_delete_restore_attributes

    original_slug = attrs[:slug]
    retry_times = 0

    self.class.transaction do
      run_callbacks(:restore) do
        if attrs[:slug]
          raise ActiveRecord::RecordNotUnique if self.class.where(slug: attrs[:slug]).any?
        end

        update_columns(attrs)
      rescue ActiveRecord::RecordNotUnique
        attrs[:slug] = "#{original_slug}-#{BlueDoc::Slug.random}"
        retry_times += 1

        if retry_times < 10
          retry
        else
          raise 2
        end
      end
    end
  end

  def restore_dependents(field)
    send(field).unscoped.where("deleted_at >= ?", deleted_at).restore_all
  end

  class_methods do
    def destroy_all
      all.each { |r| r.destroy }
    end

    def restore_all
      all.each { |r| r.restore }
    end
  end
  # PRO-end
end
