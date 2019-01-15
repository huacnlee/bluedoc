TranslationIO.configure do |config|
  config.api_key        = 'e6d189c3fc1047e084f2db76cafd4d9e'
  config.source_locale  = 'en'
  config.target_locales = ['zh-CN']

  # Uncomment this if you don't want to use gettext
  config.disable_gettext = true

  # Uncomment this if you already use gettext or fast_gettext
  # config.locales_path = File.join('path', 'to', 'gettext_locale')

  # Find other useful usage information here:
  # https://github.com/translation/rails#readme
end