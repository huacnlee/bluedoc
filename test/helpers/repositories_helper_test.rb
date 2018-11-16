# frozen_string_literal: true

require "test_helper"

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
end
