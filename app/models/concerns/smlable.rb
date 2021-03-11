# frozen_string_literal: true

module Smlable
  extend ActiveSupport::Concern

  included do
    has_rich_text :body
    has_rich_text :body_sml

    validates :format, inclusion: %w[markdown sml html]
  end

  def body_plain
    body.to_s
  end

  def body_sml_plain
    body_sml.to_s
  end

  def body_html
    render_body_html(body_sml_plain, body_plain, format: self.format)
  end

  def body_public_html
    render_body_html(body_sml_plain, body_plain, format: self.format, public: true)
  end

  def draft_body_html
    render_body_html(draft_body_sml_plain, draft_body_plain, format: self.format)
  end

  private

  def render_body_html(sml, markdown, opts = {})
    if opts[:format].to_sym == :sml
      begin
        return BlueDoc::HTML.render(sml, format: :sml, public: opts[:public])
      rescue => e
        BlueDoc::Error.track(e,
          title: "doc:#{id} body_html with SML render faield, fallback to markdown",
          body: sml)
        return BlueDoc::HTML.render(markdown, format: :markdown, public: opts[:public])
      end
    end

    BlueDoc::HTML.render(markdown, format: :markdown, public: opts[:public])
  end
end
