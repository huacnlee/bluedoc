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
    case self.format
    when "sml"
      BookLab::HTML.render(self.body_sml_plain, format: :sml)
    else
      BookLab::HTML.render(self.body_plain, format: self.format)
    end
  end

  def body_public_html
    case self.format
    when "sml"
      BookLab::HTML.render(self.body_sml_plain, format: :sml, public: true)
    else
      BookLab::HTML.render(self.body_plain, format: self.format, public: true)
    end
  end
end
