# frozen_string_literal: true

module BlueDoc
  # Sanitize
  # From: https://github.com/ruby-china/homeland/blob/master/lib/homeland/sanitize.rb
  module Sanitize
    # https://github.com/rgrove/sanitize#example-transformer-to-whitelist-youtube-video-embeds
    EMBED_VIDEO_TRANSFORMER = lambda do |env|
      node      = env[:node]
      node_name = env[:node_name]

      # Don't continue if this node is already whitelisted or is not an element.
      return if env[:is_whitelisted] || !node.element?

      # Don't continue unless the node is an iframe.
      return unless node_name == "iframe"

      # Verify that the video URL is actually a valid YouTube video URL.
      valid_video_url = false

      return if node["src"].blank?

      # Youtube
      if node["src"].match?(%r{\A(?:https?:)?//(?:www\.)?youtube(?:-nocookie)?\.com/embed/})
        valid_video_url = true
      end

      # Vimeo
      if node["src"].start_with?("https://player.vimeo.com/video/")
        valid_video_url = true
      end

      # Youku
      if node["src"].match?(%r{\A(?:http[s]{0,1}?:)?//player\.youku\.com/embed/})
        valid_video_url = true
      end

      return unless valid_video_url

      # We're now certain that this is a YouTube embed, but we still need to run
      # it through a special Sanitize step to ensure that no unwanted elements or
      # attributes that don't belong in a YouTube embed can sneak in.
      ::Sanitize.node!(node, elements: %w[iframe],
                             attributes: {
                               "iframe" => %w[allowfullscreen class frameborder height src width]
                             })

      # Now that we're sure that this is a valid YouTube embed and that there are
      # no unwanted elements or attributes hidden inside it, we can tell Sanitize
      # to whitelist the current node.
      { node_whitelist: [node] }
    end

    DEFAULT = ::Sanitize::Config.freeze_config(
      elements: %w[
        div p br img h1 h2 h3 h4 h5 h6 blockquote pre code b i del
        strong em strike del u a ul ol li span hr embed
        table tr th td tbody thead tfoot video source
      ],
      attributes: ::Sanitize::Config.merge({},
       {
         # Here must use :all not "all"
         :all  => ["class", "nid", "id", "lang", "style", "title", "width", "height", :data],
         "a"   => ["href", "rel", "target"],
         "img" => ["alt", "src"],
         "source" => ["src", "type"],
         "video" => ["controls", "preload"],
         "embed" => ["src", "width", "height", "title"],
       }
      ),
      css: {
        properties: %w[width height text-align text-indent padding-left color background background-color],
      },
      protocols: {
        "a" => { "href" => ["http", "https", "mailto", :relative] },
        "img" => { "src" => ["http", "https", :relative] },
        "source" => { "src" => ["http", "https", :relative] }
      },
      transformers: [EMBED_VIDEO_TRANSFORMER]
    )
  end
end
