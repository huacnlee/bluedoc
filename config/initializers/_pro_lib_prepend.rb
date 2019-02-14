# frozen_string_literal: true

# Load pro/lib file first for prepend lib/**

# PRO-begin
pro_lib_paths = Dir.glob(Rails.root.join("lib/**/*.rb")).each_with_object([]) do |path, memo|
  pro_path = Rails.root.join("pro", Pathname.new(path).relative_path_from(Rails.root))
  memo << pro_path.to_s if pro_path.exist?
end

pro_lib_paths.each do |filepath|
  require filepath.gsub("/pro/lib/", "/lib/")
  require filepath
end
# PRO-end
