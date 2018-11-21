ActiveSupport.on_load(:active_storage_blob) do
  ActiveStorage::Attachment.send(:second_level_cache, expires_in: 1.week)
  ActiveStorage::Blob.send(:second_level_cache, expires_in: 1.week)
end