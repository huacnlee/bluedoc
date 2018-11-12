module SearchesHelper
  def highlight(body)
    sanitize_html body.gsub(/([^a-z0-9])\s+([^a-z0-9])/, "\\1\\2").gsub("{{b}}", raw("<b>")).gsub("{{/b}}", raw("</b>"))
  end
end