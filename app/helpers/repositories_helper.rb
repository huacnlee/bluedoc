# frozen_string_literal: true

module RepositoriesHelper
  def repository_name_tag(repo, opts = {})
    return "" if repo.blank?
    return "" if repo.user.blank?

    if opts[:with_icon]
      link_to icon_tag("repo", label: repo.name), repo.to_path, class: "repository-name icon-middle-wrap"
    else
      link_to repo.name, repo.to_path, class: "repository-name"
    end
  end

  def repository_path_tag(repo)
    return "" if repo.blank?
    return "" if repo.user.blank?

    divider = %(<span class="divider">/</span>)

    text = safe_join([repo.user.name, repo.name], raw(divider))

    link_to(text, repo.to_path, class: "repository-path")
  end
end
