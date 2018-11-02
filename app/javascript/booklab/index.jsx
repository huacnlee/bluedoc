import Turbolinks from "turbolinks"
import ReactDOM from "react-dom"
import React from "react"
import "@babel/polyfill"
import "actiontext"
import "primer-booklab"
import "vendor/styleguide.js"
import "vendor/jquery.timeago.js"
import "vendor/jquery.timeago.settings.js"
import MarkdownEditor from './editor/index'
import './reader/index.js'

Turbolinks.start()
window.$ = jQuery

window.App = {
  locale: 'en'
}

document.addEventListener("turbolinks:load", () => {
  $(".timeago").timeago()

  const editorEls = document.getElementsByClassName("booklab-editor");
  if (editorEls.length > 0) {
    const editorInput = editorEls[0];
    editorInput.hidden = true;

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
