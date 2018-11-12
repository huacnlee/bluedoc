module BookLab
  class Search
    class << self
      def prepare_data(search_data, purpose = :query)
        purpose ||= :query

        data = search_data.dup
        data.force_encoding("UTF-8")

        if ['zh-TW', 'zh-CN', 'ja'].include?(Setting.default_locale)
          require 'cppjieba_rb' unless defined? CppjiebaRb
          mode = (purpose == :query ? :query : :mix)
          data = CppjiebaRb.segment(search_data, mode: mode)
          data = CppjiebaRb.filter_stop_word(data).join(' ')
        end

        data.squish!
        data
      end

      def ts_config(locale = nil)
        locale ||= Setting.default_locale

        locale = locale.underscore.to_sym

        case locale
        when :da     then 'danish'
        when :de     then 'german'
        when :en     then 'english'
        when :es     then 'spanish'
        when :fr     then 'french'
        when :it     then 'italian'
        when :nl     then 'dutch'
        when :nb_no then 'norwegian'
        when :pt     then 'portuguese'
        when :pt_br  then 'portuguese'
        when :sv     then 'swedish'
        when :ru     then 'russian'
        else 'simple' # use the 'simple' stemmer for other languages
        end
      end
    end
  end
end