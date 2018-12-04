require 'test_helper'

class ShareTest < ActiveSupport::TestCase
  test "base create" do
    doc = create(:doc)
    share = create(:share, shareable: doc)
    assert_equal false, share.new_record?
    assert_equal doc.repository_id, share.repository_id
    assert_equal "Doc", share.shareable_type
    assert_equal doc.id, share.shareable_id
    assert share.slug.length > 6
    assert_equal "/shares/#{share.slug}", share.to_path
    assert_equal "#{Setting.host}#{share.to_path}", share.to_url

    assert_equal share, doc.share
    assert_equal true, doc.repository.shares.include?(share)

    res = Share.find_by_slug!(share.slug)
    assert_equal share, res

    assert_raise(ActiveRecord::RecordNotFound) { Share.find_by_slug!("not-exist-slug") }

    # doc depends destroy share
    doc.destroy
    assert_nil Share.find_by_id(share.id)
  end

  test "repository depends destroy" do
    repo = create(:repository)
    doc0 = create(:doc, repository: repo)
    doc1 = create(:doc, repository: repo)
    share0 = create(:share,  shareable: doc0, repository_id: repo.id)
    share1 = create(:share,  shareable: doc1, repository_id: repo.id)

    assert_equal 2, Share.where(repository_id: repo.id).count
    repo.destroy
    assert_equal 0, Share.where(repository_id: repo.id).count
  end

  test "create_share" do
    doc = create(:doc)
    user = create(:user)

    share = Share.create_share(doc, user: user)
    assert_equal false, share.new_record?
    assert_equal share, Share.find_by_slug!(share.slug)

    share1 = Share.create_share(doc, user: user)
    assert_equal share, share1
  end
end
