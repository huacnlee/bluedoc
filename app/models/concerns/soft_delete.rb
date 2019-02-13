
# frozen_string_literal: true

module SoftDelete
  extend ActiveSupport::Concern

  included do
    default_scope -> { where(deleted_at: nil) }

    # PRO-begin
    define_callbacks :soft_delete, :restore
    alias_method :destroy!, :destroy
    # PRO-end
  end

  def destroy
    attrs = { deleted_at: Time.now.utc, updated_at: Time.now.utc }
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
    attrs = { deleted_at: nil, updated_at: Time.now.utc }
    attrs = soft_delete_restore_attributes if defined? soft_delete_restore_attributes

    original_slug = attrs[:slug]
    retry_times = 0

    self.class.transaction do
      run_callbacks(:restore) do
        begin
          if attrs[:slug]
            raise ActiveRecord::RecordNotUnique if self.class.where(slug: attrs[:slug]).any?
          end

          update_columns(attrs)
        rescue ActiveRecord::RecordNotUnique => e
          attrs[:slug] = "#{original_slug}-#{BookLab::Slug.random}"
          retry_times += 1

          if retry_times < 10
            retry
          else
            raise 2
          end
        end
      end
    end
  end

  def restore_dependents(field)
    self.send(field).unscoped.where("deleted_at >= ?", self.deleted_at).restore_all
  end

  def deleted?
    deleted_at.present?
  end

  class_methods do
    def destroy_all
      all.each { |r| r.restore }
    end

    def restore_all
      all.each { |r| r.restore }
    end
  end
end
