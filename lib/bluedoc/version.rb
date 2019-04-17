# frozen_string_literal: true

module BlueDoc
  VERSION = "1.0.2"

  def self.full_version
    version_str = VERSION
    if ENV["BLUEDOC_BUILD_VERSION"]
      version_str += " (build #{ENV["BLUEDOC_BUILD_VERSION"]})"
    end

    version_str
  end
end
