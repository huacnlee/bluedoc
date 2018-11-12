module SearchesHelper
  def highlight(body)
    body ||= ""
    if body.is_a?(String)
      body = [body]
    end

    sanitize_html body.join("").gsub("[h]", raw("<b class='text-red'>")).gsub("[/h]", raw("</b>"))
  end
end