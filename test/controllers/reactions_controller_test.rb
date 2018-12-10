# frozen_string_literal: true

require "test_helper"

class ReactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = create(:user)
  end

  test "POST /user/reactions" do
    group = create(:group)
    repo = create(:repository, user: group, privacy: :private)
    doc = create(:doc, repository: repo)
    t = doc.updated_at

    reaction_params = {
      subject_type: "Doc",
      subject_id: doc.id,
      content: "+1"
    }

    post reactions_path, params: { reaction: reaction_params }, xhr: true
    assert_equal 401, response.status

    sign_in @user
    post reactions_path, params: { reaction: reaction_params }, xhr: true
    assert_equal 403, response.status

    sign_in_role :reader, group: group
    assert_changes -> { Reaction.where(subject: doc, name: "+1").count }, 1 do
      post reactions_path, params: { reaction: reaction_params }, xhr: true
      assert_equal 200, response.status
      assert_match %($("#Doc-#{doc.id}-reaction-box").replaceWith), response.body
      doc.reload
      assert_not_equal t, doc.updated_at
    end

    get doc.to_path
    assert_equal 200, response.status
    assert_select "#Doc-#{doc.id}-reaction-box" do
      assert_select ".reaction-list button.btn-link" do
        assert_select "[name='reaction[content]']"
        assert_select "[value=?]", "+1 unset"
        assert_select "img[src=?]", Reaction.new(name: "+1").url
      end
    end

    reaction_params[:content] = "+1 unset"
    assert_changes -> { Reaction.where(subject: doc, name: "+1").count }, -1 do
      t = doc.updated_at
      post reactions_path, params: { reaction: reaction_params }, xhr: true
      assert_equal 200, response.status
      doc.reload
      assert_not_equal t, doc.updated_at
    end
  end
end
