# frozen_string_literal: true

require "test_helper"

class BookLab::SearchText < ActionView::TestCase
  test "prepare_data" do
    search_data = "Hello  this is  english  content"
    assert_equal "Hello this is english content", BookLab::Search.prepare_data(search_data)

    locales = %w[zh-CN zh-TW ja]
    locales.each do |locale|
      Setting.stub(:default_locale, locale) do
        search_data = "こんにちは、これは検索コンテンツです，你好，这是中文搜索文本"
        assert_equal "こ ん に ち は こ れ は 検 索 コ ン テ ン ツ で す 你好 这是 中文 搜索 中文搜索 文本", BookLab::Search.prepare_data(search_data)
      end
    end

    locales = %w[zh-CN zh-TW ja]
    locales.each do |locale|
      Setting.stub(:default_locale, locale) do
        search_data = "こんにちは、これは検索コンテンツです，你好，这是中文搜索文本"
        assert_equal "こ ん に ち は こ れ は 検 索 コ ン テ ン ツ で す 你好 这是 中文搜索 文本", BookLab::Search.prepare_data(search_data, :mix)
      end
    end
  end

  test "ts_config" do
    locale_map = {
      "da" => 'danish',
      "de" => 'german',
      "en" => 'english',
      "es" => 'spanish',
      "fr" => 'french',
      "it" => 'italian',
      "nl" => 'dutch',
      "nb-NO" => 'norwegian',
      "pt" => 'portuguese',
      "pt-BR" => 'portuguese',
      "sv" => 'swedish',
      "ru" => 'russian',
      "zh-CN" => 'simple',
      "zh-TW" => 'simple',
      "ja" => 'simple'
    }

    locale_map.each_key do |key|
      assert_equal locale_map[key], BookLab::Search.ts_config(key)
    end

    Setting.stub(:default_locale, "de") do
      assert_equal "german", BookLab::Search.ts_config
    end

    Setting.stub(:default_locale, "zh-CN") do
      assert_equal "simple", BookLab::Search.ts_config
    end
  end
end