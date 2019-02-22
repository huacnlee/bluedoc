# frozen_string_literal: true

require "test_helper"

class DocsHelperTest < ActionView::TestCase
  test "doc_title_tag" do
    group = create(:group)
    repo = create(:repository, user: group)
    doc = create(:doc, repository: repo)

    assert_equal %(<a class="doc-link" title="#{doc.title}" href="#{doc.to_path}">#{doc.title}</a>), doc_title_tag(doc)

    assert_equal %(), doc_title_tag(nil)

    doc.stub(:repository, nil) do
      assert_equal %(), doc_title_tag(doc)
    end

    repo.stub(:user, nil) do
      doc.stub(:repository, repo) do
        assert_equal %(), doc_title_tag(doc)
      end
    end
  end
end
