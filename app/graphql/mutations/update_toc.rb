# frozen_string_literal: true

class Mutations::UpdateToc < Mutations::BaseMutation
  argument :id, ID, required: true, description: "Toc primary id"
  argument :title, String, required: false, description: "Toc title (will sync Doc title if relative exist)"
  argument :url, String, required: false, description: "Toc item url (will sync Doc slug if relative exist)"

  type Boolean

  def resolve(id:, title: nil, url: nil)
    @toc = Toc.find(id)

    authorize! :create_doc, @toc.repository

    update_params = {}
    update_params[:title] = title if title
    update_params[:url] = url if url

    @toc.update(update_params)
    if @toc.doc
      @toc.doc.update(title: @toc.title, slug: @toc.url)
    end

    true
  end
end
