import Turbolinks from "turbolinks"
import ReactDOM from "react-dom"
import React from "react"
import "@babel/polyfill"
import "actiontext"
import "primer-booklab"
import "vendor/styleguide.js"
import "vendor/jquery.timeago.js"
import "vendor/jquery.timeago.settings.js"
import './rails-ujs-extends'

import MarkdownEditor from './editor/index'

Turbolinks.start()
window.$ = jQuery
window.App = {
  locale: 'en'
}

import './reader/index.js'
import './follow-user/index.js'
import './comments/index.js'
import './mentionable/index.js'

document.addEventListener("turbolinks:before-cache", () => {
  // clean auto save
  if (window.editorAutosaveTimer) {
    clearInterval(window.editorAutosaveTimer)
  }
})

document.addEventListener("turbolinks:load", () => {
  $(".timeago").timeago()

  const editorEls = document.getElementsByClassName("booklab-editor");
  if (editorEls.length > 0) {
    const editorInput = editorEls[0];
    editorInput.hidden = true;
    const editorMessage = $(".editor-message");

    const titleInput = document.getElementsByName("doc[title]")[0];
    const slugInput = document.getElementsByName("doc[slug]")[0];

    const editorDiv = document.createElement("div");
    editorDiv.className = "editor-container";

    const onChange = (value) => {
      editorInput.value = value
    }

    const onChangeTitle = (value) => {
      titleInput.value = value
    }

    const onChangeSlug = (value) => {
      slugInput.value = value
    }

    // Save button
    $(".btn-save").click((e) => {
      const $btn = $(e.currentTarget)
      const url = $btn.attr("data-url")
      editorMessage.show()
      editorMessage.text("saving...")

      $.ajax({
        method: "PUT",
        url: url,
        dataType: "JSON",
        data: {
          doc: {
            draft_title: titleInput.value,
            draft_body: editorInput.value,
          },
        },
        success: (res) => {
          editorMessage.text("saved")
          setTimeout(() => editorMessage.fadeOut(), 3000)
        }
      })

      return false;
    })

    window.editorAutosaveTimer = setInterval(() => {
      $(".btn-save").trigger("click")
    }, 15000);

    $("form").after(editorDiv);
    ReactDOM.render(
      <MarkdownEditor name="MarkdownEditor"
        onChange={onChange}
        onChangeTitle={onChangeTitle}
        onChangeSlug={onChangeSlug}
        directUploadURL={editorInput.attributes["data-direct-upload-url"].value}
        blobURLTemplate={editorInput.attributes["data-blob-url-template"].value}
        title={titleInput.value}
        slug={slugInput.value}
        value={editorInput.value} />,
      editorDiv,
    )
  }
})
