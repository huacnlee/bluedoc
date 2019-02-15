# frozen_string_literal: true

module BlueDoc
  class HTML
    # Extract mention fragments in a html
    def self.mention_fragments(html, username)
      return [] if html.blank?
      return [] if username.blank?

      doc = Nokogiri::HTML(html)
      username_href = "/#{username}"

      fragments = []
      doc.search("a.user-mention").each do |node|
        next unless node.attr("href") == username_href

        parent = node.ancestors("p,blockquote,h1,h2,h3,h4,h5,h6,ul,ol").first
        if parent
          # remove heading anchor
          parent.search("a.heading-anchor").remove
          text = parent.inner_text
        else
          text = node.parent&.inner_text || ""
        end

        fragments << text.strip
      end

      fragments
    end
  end
end
