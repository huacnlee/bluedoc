# frozen_string_literal: true

require "test_helper"

class RepositoriesHelperTest < ActionView::TestCase
  include ApplicationHelper

  setup do
    @user = create(:user)
    @repo = create(:repository, user: @user)

    sign_in @user
  end

  def current_user; @user; end

  test "repository_name_tag" do
    assert_equal "", repository_name_tag(nil)

    html = repository_name_tag(@repo)
    assert_equal %(<a class="repository-name" href="#{@repo.to_path}">#{@repo.name}</a>), html
  end

  test "repository_path_tag" do
    assert_equal "", repository_name_tag(nil)

    html = repository_path_tag(@repo)
    assert_equal %(<a class="repository-path" href="#{@repo.to_path}">#{@user.name}<span class="divider">/</span>#{@repo.name}</a>), html

    @repo.stub(:name, "<script>") do
      @user.stub(:name, "<foo>") do
        html = repository_path_tag(@repo)
        assert_equal %(<a class="repository-path" href="#{@repo.to_path}">&lt;foo&gt;<span class="divider">/</span>&lt;script&gt;</a>), html
      end
    end
  end
end
