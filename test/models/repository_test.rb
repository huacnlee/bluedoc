# frozen_string_literal: true

require "test_helper"

class RepositoryTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  test "Slugable" do
    repo = create(:repository, slug: "FooBar")
    assert_equal repo, Repository.where(user_id: repo.user_id).find_by_slug(repo.slug)
    assert_equal repo, Repository.where(user_id: repo.user_id).find_by_slug(repo.slug.upcase)

    assert_raise(ActiveRecord::RecordNotFound) { Repository.where(user_id: repo.user_id).find_by_slug!("not-exist-repo") }

    assert_equal "/#{repo.user.slug}/#{repo.slug}", repo.to_path

    # slug unique with case insensitive
    repo1 = build(:repository, slug: "foobar")
    assert_equal true, repo1.valid?
    repo2 = build(:repository, user_id: repo.user_id, slug: "foobar")
    assert_equal false, repo2.valid?
    assert_equal ["has already been taken"], repo2.errors[:slug]

    # auto format slug
    repo3 = build(:repository, slug: " Ruby on Rails ")
    assert_equal true, repo3.valid?
    assert_equal "Ruby-on-Rails", repo3.slug
  end

  test "validation" do
    repo = build(:repository, slug: "Hello")
    assert_equal true, repo.valid?

    repo.slug = "Hello-This_123"
    assert_equal true, repo.valid?
    assert_equal "Hello-This_123", repo.slug

    repo.slug = "Hello This_123"
    assert_equal true, repo.valid?
    assert_equal "Hello-This_123", repo.slug

    repo.slug = "H"
    assert_equal false, repo.valid?

    repo = build(:repository, slug: "foo", gitbook_url: nil)
    assert_equal true, repo.valid?
  end

  test "slug validation" do
    assert_equal true, build(:repository, slug: "foo").valid?

    repo = build(:repository, slug: "notes")
    assert_equal false, repo.valid?
    assert_equal ["invalid, [#{repo.slug}] is a keyword."], repo.errors[:slug]
  end

  test "slug" do
    group = create(:group)
    repo = build(:repository, user: group, slug: "help")
    assert_equal "/#{group.slug}/#{repo.slug}", repo.to_path
    assert_equal "#{Setting.host}/#{group.slug}/#{repo.slug}", repo.to_url
  end

  test "fullname" do
    repo = build(:repository, name: "BlueDoc Help", slug: "help")
    assert_equal "BlueDoc Help (help)", repo.fullname
  end

  test "auto member watch" do
    group = create(:group)
    user1 = create(:user)
    group.add_member(user1, :editor)
    user2 = create(:user)
    group.add_member(user2, :reader)
    group.reload

    repo = create(:repository, user: group)
    assert_equal group.member_user_ids.sort, repo.watch_by_user_ids.sort
    assert_equal 2, repo.watches_count

    assert_equal true, user1.watch_repository?(repo)
    assert_equal true, user2.watch_repository?(repo)

    # for User
    user = create(:user)
    repo = create(:repository, user: user)
    assert_equal [user.id], repo.watch_by_user_ids
    assert_equal true, user.watch_repository?(repo)
    assert_equal 1, repo.watches_count
  end

  test "destroy dependent :user_actives" do
    user0 = create(:user)
    user1 = create(:user)
    repo = create(:repository)

    UserActive.track(repo, user: user0)
    UserActive.track(repo, user: user1)
    assert_equal 2, UserActive.where(subject: repo).count

    repo.destroy
    assert_equal 0, UserActive.where(subject: repo).count
  end

  test "destroy dependent :docs" do
    repo = create(:repository)
    docs = create_list(:doc, 2, repository: repo)

    assert_changes -> { Doc.count }, -2 do
      repo.destroy
    end
    assert_equal 0, Doc.where(id: docs.collect(&:id)).count
  end

  test "private dependent :activites" do
    repo = create(:repository)
    doc = create(:doc)
    create(:activity, target: repo)
    create(:activity, target: repo)
    create(:activity, target: doc, repository_id: repo.id)
    assert_equal 2, Activity.where(target: repo).count
    assert_equal 1, Activity.where(repository_id: repo.id).count

    repo.update(name: "new name", privacy: :public)
    assert_equal 2, Activity.where(target: repo).count
    assert_equal 1, Activity.where(repository_id: repo.id).count

    repo.update(privacy: :private)
    assert_equal 0, Activity.where(target: repo).count
    assert_equal 0, Activity.where(repository_id: repo.id).count
  end

  test "track user active on create" do
    user = create(:user)
    mock_current(user: user)
    repo = create(:repository)
    assert_equal 1, user.user_actives.where(subject: repo).count
    assert_equal 1, user.user_actives.where(subject: repo.user).count

    # update should not track
    user1 = create(:user)
    mock_current(user: user1)
    assert_no_changes -> { UserActive.count } do
      repo.update(updated_at: Time.now)
    end
    assert_equal 0, user1.user_actives.where(subject: repo).count
  end

  test "preferences" do
    repo = create(:repository)

    # TOC
    assert_nil repo.preferences[:has_toc]
    assert_equal true, repo.has_toc?

    repo.preferences[:has_toc] = 1
    assert_equal 1, repo.has_toc
    assert_equal true, repo.has_toc?

    repo.has_toc = 0
    assert_equal 0, repo.preferences[:has_toc]
    assert_equal 0, repo.has_toc
    assert_equal false, repo.has_toc?

    repo.has_toc = nil
    assert_equal true, repo.has_toc?
    repo.has_toc = "1"
    assert_equal true, repo.has_toc?
    repo.has_toc = "true"
    assert_equal true, repo.has_toc?
    repo.has_toc = "0"
    assert_equal false, repo.has_toc?

    repo.save
    repo.reload

    assert_equal({ "has_toc" => "0" }, repo.preferences)

    # Issues
    assert_nil repo.preferences[:has_issues]
    repo.has_issues = 0
    assert_equal 0, repo.preferences[:has_issues]
    assert_equal false, repo.has_issues?
    repo.has_issues = 1
    assert_equal 1, repo.preferences[:has_issues]
    assert_equal true, repo.has_issues?
    repo.has_issues = "1"
    assert_equal true, repo.has_issues?
    repo.has_issues = "true"
    assert_equal true, repo.has_issues?
    repo.has_issues = "0"
    assert_equal false, repo.has_issues?
    repo.has_issues = nil
    assert_equal true, repo.has_issues?
  end

  test "toc_text / toc_html / toc_json" do
    toc = [{ title: "Hello world", url: "/hello", id: nil, depth: 0 }.as_json].to_yaml.strip
    repo = create(:repository, toc: toc)
    assert_equal toc, repo.toc_text
    assert_equal [].to_yaml, repo.toc_by_docs_text
    assert_html_equal BlueDoc::Toc.parse(toc).to_html, repo.toc_html
    assert_html_equal BlueDoc::Toc.parse(toc).to_html(prefix: "/prefix"), repo.toc_html(prefix: "/prefix")
    assert_html_equal BlueDoc::Toc.parse(toc).to_json, repo.toc_json
    assert_html_equal BlueDoc::Toc.parse([].to_yaml).to_json, repo.toc_by_docs_json

    repo = create(:repository, toc: nil)
    assert_equal [].to_yaml, repo.toc_text

    doc1 = create(:doc, repository: repo)
    toc_hash = [{ title: doc1.title, depth: 0, id: doc1.id, url: doc1.slug }.as_json]
    toc = toc_hash.to_yaml
    assert_equal toc, repo.toc_text
    assert_equal toc, repo.toc_by_docs_text
    assert_html_equal BlueDoc::Toc.parse(toc).to_html, repo.toc_html
    assert_html_equal BlueDoc::Toc.parse(toc).to_json, repo.toc_json
    assert_html_equal BlueDoc::Toc.parse(toc).to_json, repo.toc_by_docs_json

    doc2 = create(:doc, repository: repo)
    toc_hash << { title: doc2.title, depth: 0, id: doc2.id, url: doc2.slug }.as_json
    toc = toc_hash.to_yaml
    assert_equal toc, repo.toc_text
    repo = Repository.find(repo.id)
    assert_equal BlueDoc::Toc.parse(toc).to_html, repo.toc_html

    # override toc as custom yml
    custom_toc = [{ title: doc2.title, depth: 0, id: doc2.id, url: doc2.slug }.as_json].to_yaml.strip
    repo.update(toc: custom_toc)
    assert_equal custom_toc, repo.toc_text
    assert_equal toc, repo.toc_by_docs_text
    assert_html_equal BlueDoc::Toc.parse(custom_toc).to_json, repo.toc_json
    assert_html_equal BlueDoc::Toc.parse(toc).to_json, repo.toc_by_docs_json
  end

  test "update_toc_by_url" do
    toc = <<~TOC
    - title: Hello
      url: hello
      depth: 0
    - title: Getting Started
      url: getting-started
      depth: 1
    - title: Database setup
      url: database-setup
      depth: 1
    TOC
    repo = create(:repository, toc: toc)

    assert_equal false, repo.update_toc_by_url("not-exist", title: "Setup database", url: "setup-database")
    assert_equal true, repo.update_toc_by_url("database-setup", title: "Setup database", url: "setup-database")

    repo.reload
    assert_match "setup-database", repo.toc_text
    content = BlueDoc::Toc.parse(repo.toc_text, format: :yml)
    item = content.find_by_url("setup-database")
    assert_not_nil item
    assert_equal "setup-database", item.url
    assert_equal "Setup database", item.title
    assert_equal 1, item.depth

    # Test parallel update
    threads = []
    threads << Thread.new do
      repo.update_toc_by_url("setup-database", title: "Update by Thread 1", url: "update-by-thread-1")
    end
    threads << Thread.new do
      repo.update_toc_by_url("getting-started", title: "Update by Thread 2", url: "update-by-thread-2")
    end
    threads << Thread.new do
      repo.update_toc_by_url("hello", title: "Update by Thread 3", url: "update-by-thread-3")
    end
    threads.each(&:join)

    repo.reload
    new_toc = <<~TOC
    ---
    - title: Update by Thread 3
      url: update-by-thread-3
      depth: 0
      id:
    - title: Update by Thread 2
      url: update-by-thread-2
      depth: 1
      id:
    - title: Update by Thread 1
      url: update-by-thread-1
      depth: 1
      id:
    TOC
    assert_equal YAML.dump(YAML.load(new_toc)), repo.toc_text
  end

  test "validate toc" do
    toc = "foo\"\"\nsdk"
    repo = build(:repository, toc: toc)
    assert_equal false, repo.valid?
    assert_equal ["Invalid TOC format (required YAML format)."], repo.errors[:toc]

    toc = <<~TOC
    - name: Hello
     slug: hello
    TOC
    repo = build(:repository, toc: toc)
    assert_equal false, repo.valid?
    assert_equal ["Invalid TOC format (required YAML format)."], repo.errors[:toc]

    toc = <<~TOC
    - title: Hello
      url: hello
    TOC
    repo = build(:repository, toc: toc)
    assert_equal true, repo.valid?
  end

  test "toc_ordered_docs" do
    repo = create(:repository)
    docs = create_list(:doc, 5, repository: repo)
    toc = <<~TOC
    - url: #{docs[2].slug}
    - url: #{docs[1].slug}
    - url: #{docs[4].slug}
    - url: #{docs[0].slug}
    - url: http://foobar.com
    TOC
    repo.update!(toc: toc)

    # Only including doc in Toc
    assert_equal [docs[2].slug, docs[1].slug, docs[4].slug, docs[0].slug], repo.toc_ordered_docs.collect(&:slug)
    assert_equal docs[2], repo.toc_ordered_docs[0]
    assert_equal docs[1], repo.toc_ordered_docs[1]
    assert_equal docs[4], repo.toc_ordered_docs[2]
    assert_equal docs[0], repo.toc_ordered_docs[3]
  end

  test "read_ordered_docs" do
    repo0 = create(:repository)
    docs = create_list(:doc, 4, repository: repo0)

    # enable toc, should return same as toc_ordered_docs
    repo0.stub(:has_toc?, true) do
      repo0.stub(:toc_ordered_docs, docs) do
        assert_equal docs, repo0.read_ordered_docs
      end
    end

    # disabled toc, return with id asc
    repo1 = create(:repository)
    doc10 = create(:doc, repository: repo1)
    doc11 = create(:doc, repository: repo1)
    doc12 = create(:doc, repository: repo1)
    repo1.stub(:has_toc?, false) do
      assert_equal [doc10, doc11, doc12], repo1.read_ordered_docs
    end
  end

  test "transfer" do
    repo = create(:repository)
    to_user = create(:user)
    actor = create(:user)

    mock_current(user: actor)
    assert_equal false, repo.transfer("not-exist")
    assert_equal ["Transfer target: [not-exist] does not exists, please check it."], repo.errors[:user_id]

    assert_equal true, repo.transfer(to_user.slug)
    assert_equal to_user.id, repo.user_id

    assert_not_equal 0, Activity.where(action: :transfer_repo, target: repo).count
  end

  test "_search_body" do
    user = create(:user)
    toc = <<~TOC
    - title: Hello
      url: hello
    TOC
    repo = create(:repository, user: user, description: "Hello world", toc: toc)

    expected = [user.fullname, repo.description, toc].join("\n\n")

    assert_equal expected.strip, repo.send(:_search_body).strip
  end

  test "as_indexed_json" do
    repo = create(:repository, description: "Hello world")
    repo.stub(:_search_body, "Search body") do
      data = { slug: repo.slug, title: repo.name, body: "Hello world", search_body: "Search body", repository_id: repo.id, user_id: repo.user_id, repository: { public: true }, deleted: false }
      assert_equal data, repo.as_indexed_json
    end

    repo = create(:repository, privacy: :private, description: "Hello world", deleted_at: Time.now)

    repo.stub(:_search_body, "Search body") do
      data = { slug: repo.slug, title: repo.name, body: "Hello world", search_body: "Search body", repository_id: repo.id, user_id: repo.user_id, repository: { public: false }, deleted: true }
      assert_equal data, repo.as_indexed_json
    end
  end

  test "indexed_changed?" do
    repo = create(:repository)

    repo = Repository.find(repo.id)
    assert_equal false, repo.indexed_changed?
    repo.updated_at = Time.now
    repo.stars_count += 1
    assert_equal false, repo.indexed_changed?

    repo.stub(:saved_change_to_privacy?, true) do
      assert_equal true, repo.indexed_changed?
    end
    repo.stub(:saved_change_to_name?, true) do
      assert_equal true, repo.indexed_changed?
    end
    repo.stub(:saved_change_to_description?, true) do
      assert_equal true, repo.indexed_changed?
    end
    repo.stub(:saved_change_to_deleted_at?, true) do
      assert_equal true, repo.indexed_changed?
    end
  end

  test "editors" do
    user0 = create(:user)
    user1 = create(:user)
    user2 = create(:user)

    repo = create(:repository, editor_ids: [user1.id, user0.id])
    assert_equal [user1.id, user0.id], repo.editor_ids

    mock_current user: user2
    toc = <<~TOC
    - title: Hello
      url: hello
    TOC
    repo.update!(toc: toc)
    repo.reload

    assert_equal [user1.id, user0.id, user2.id], repo.editor_ids
    assert_equal [user1, user0, user2], repo.editors
  end
end
