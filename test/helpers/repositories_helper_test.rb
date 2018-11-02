require 'test_helper'

class RepositoriesHelperTest < ActionView::TestCase
  include ApplicationHelper

  setup do
    @user = create(:user)
    @repository = create(:repository, user: @user)

    sign_in @user
  end

  def current_user; @user; end

  test "repository_name_tag" do
    assert_equal "", repository_name_tag(nil)

    html = repository_name_tag(@repository)
    assert_equal %(<a class="repository-name" href="#{@repository.to_path}">#{@repository.name}</a>), html
  end

  test "repository_path_tag" do
    assert_equal "", repository_name_tag(nil)

    html = repository_path_tag(@repository)
    assert_equal %(<a class="repository-path" href="#{@repository.to_path}">#{@user.name} / #{@repository.name}</a>), html
  end

  test "action_button_tag" do
    assert_equal "", action_button_tag(nil, :watch)
    html = action_button_tag(@repository, :watch, icon: "eye", with_count: true)
    assert_action_button html, @repository, :watch, text: "Watch", label: "Watch", undo_label: "Unwatch", icon: "eye", method: :post, with_count: true

    @user.watch_repository(@repository)
    html = action_button_tag(@repository, :watch, icon: "eye", with_count: true)
    assert_action_button html, @repository, :watch, text: "Unwatch", label: "Watch", undo_label: "Unwatch", icon: "eye", method: :delete, with_count: true

    repo1 = create(:repository)
    html = action_button_tag(repo1, :star, label: "Do Star", undo_label: "Undo Star", icon: "star", with_count: true)
    assert_action_button html, repo1, :star, text: "Do Star", label: "Do Star", undo_label: "Undo Star", icon: "star", method: :post, with_count: true
  end

  test "action_button_tag without_count" do
    html = action_button_tag(@repository, :watch, icon: "eye", undo: true)
    assert_action_button html, @repository, :watch, text: "Unwatch", label: "Watch", undo_label: "Unwatch", icon: "eye", method: :delete, with_count: false

    html = action_button_tag(@repository, :star, undo: true)
    assert_action_button html, @repository, :star, text: "Unstar", label: "Star", undo_label: "Unstar", icon: "star", method: :delete, with_count: false
  end

  private
    def assert_action_button(html, repo, action_type, text:, label:, undo_label:, icon:, method:, with_count: false)
      action_count = "#{action_type.to_s.pluralize}_count"

      icon_html = raw(icon_tag(icon, label: text))

      count_html = ""
      if with_count
        count_html = raw(%(<button class="social-count" href="#url">#{repo.send(action_count)}</button>))
      end
      btn_class = "btn btn-sm"
      btn_class += " btn-with-count" if with_count

      expected = <<~TEXT
        <div class="repository-#{repo.id}-#{action_type}-button">
        <a data-method="#{method}" data-label="#{label}" data-undo-label="#{undo_label}" data-remote="true" class="#{btn_class}" href="/#{repo.user&.slug}/#{repo.slug}/action?action_type=#{action_type}">
        #{icon_html}
        </a>
        #{count_html}
        </div>
       TEXT
      assert_equal expected.gsub(/\n/,""), html
    end
end
