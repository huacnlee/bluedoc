# frozen_string_literal: true

require "application_system_test_case"

class IssuesTest < ApplicationSystemTestCase
  setup do
    @issue = issues(:one)
  end

  test "visiting the index" do
    visit issues_url
    assert_selector "h1", text: "Issues"
  end

  test "creating a Issue" do
    visit issues_url
    click_on "New Issue"

    fill_in "Author", with: @issue.author_id
    fill_in "Description", with: @issue.description
    fill_in "Iid", with: @issue.iid
    fill_in "Last edited at", with: @issue.last_edited_at
    fill_in "Last editor", with: @issue.last_editor_id
    fill_in "Repository", with: @issue.repository_id
    fill_in "Status", with: @issue.status
    fill_in "Title", with: @issue.title
    click_on "Create Issue"

    assert_text "Issue was successfully created"
    click_on "Back"
  end

  test "updating a Issue" do
    visit issues_url
    click_on "Edit", match: :first

    fill_in "Author", with: @issue.author_id
    fill_in "Description", with: @issue.description
    fill_in "Iid", with: @issue.iid
    fill_in "Last edited at", with: @issue.last_edited_at
    fill_in "Last editor", with: @issue.last_editor_id
    fill_in "Repository", with: @issue.repository_id
    fill_in "Status", with: @issue.status
    fill_in "Title", with: @issue.title
    click_on "Update Issue"

    assert_text "Issue was successfully updated"
    click_on "Back"
  end

  test "destroying a Issue" do
    visit issues_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Issue was successfully destroyed"
  end
end
