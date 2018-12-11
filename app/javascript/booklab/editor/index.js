import React from "react"
import CoreEditor from "slate-react";
import Editor from "rich-md-editor"
import { AttachmentUpload } from "./attachment_upload"
import { Toolbar } from "./toolbar"

class MarkdownEditor extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      value: props.value,
      directUploadURL: props.directUploadURL,
      blobURLTemplate: props.blobURLTemplate,
      title: props.title,
      slug: props.slug,
    }

    this.editor = null;
  }

  setEditorRef = (ref) => {
    this.editor = ref;
    // Force re-render to show ToC (<Content />)
    this.setState({ editorLoaded: true });
  }

  onChange = (value) => {
    this.props.onChange(value())
    this.setState({ value })
  }

  onChangeTitle = (e) => {
    const newTitle = e.target.value
    this.props.onChangeTitle(newTitle)
    this.setState({ title: newTitle })
  }

  onChangeSlug = (e) => {
    const newSlug = e.target.value
    this.props.onChangeSlug(newSlug)
    this.setState({ slug: newSlug })
  }

  // Render the editor.
  render() {
    const { value, title, slug } = this.state;
    const { directUploadURL, blobURLTemplate } = this.state;

    const slugPrefix = window.location.href.split("/docs")[0] + "/docs/";
    return <div>
      {this.editor && (
        <Toolbar value={this.state.editorValue} editor={this.editor} />
      )}
      <div className="editor-bg">
        <div className="editor-box">
          <div className="editor-title">
            <input
              type="text"
              value={title}
              placeholder="Document title"
              onChange={this.onChangeTitle}
              className="editor-title-text" />
          </div>
          <div className="editor-slug">
            <input
              type="text"
              value={slug}
              placeholder="set the URL path for this doc"
              onChange={this.onChangeSlug}
              className="editor-slug-text" />
          </div>
          <Editor
            innerRef={this.setEditorRef}
            readOnly={false}
            defaultValue={value}
            className="editor-text markdown-body"
            onChange={this.onChange}
            uploadImage={async (file) => {
              return new Promise(resolve => {
                const upload = new AttachmentUpload(file, directUploadURL, blobURLTemplate, (url) => {
                  return resolve(url)
                })
                upload.start()
              })
            }}
            uploadFile={async (file) => {
              return new Promise(resolve => {
                const upload = new AttachmentUpload(file, directUploadURL, blobURLTemplate, (url) => {
                  return resolve(url)
                })
                upload.start()
              })
            }}
           />
        </div>
      </div>
    </div>
  }
}

class EditorBox {
  static init() {
    const editorEls = document.getElementsByClassName("booklab-editor");
    if (editorEls.length == 0) {
      return;
    }

    // clean auto save
    if (window.editorAutosaveTimer) {
      clearInterval(window.editorAutosaveTimer)
    }

    const saveButton = $(".btn-save");
    const saveURL = saveButton.attr("data-url");
    const lockURL = saveURL + "/lock";

    // unload to unlock doc
    window.addEventListener("beforeunload", () => {
      $.post(lockURL + "?unlock=true");
    })

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

    if ($("#doc-lock-box").length > 0) {
      return;
    }

    // Save button
    saveButton.click((e) => {
      const $btn = $(e.currentTarget)
      editorMessage.show()
      editorMessage.html("<i class='fas fa-clock'></i> saving...")

      $.ajax({
        method: "PUT",
        url: saveURL,
        dataType: "JSON",
        data: {
          doc: {
            draft_title: titleInput.value,
            draft_body: editorInput.value,
          },
        },
        success: (res) => {
          editorMessage.html("<i class='fas fa-check'></i> saved")
          setTimeout(() => editorMessage.fadeOut(), 3000)
        }
      })

      return false;
    });

    window.editorAutosaveTimer = setInterval(() => {
      $.post(lockURL);
      saveButton.trigger("click");
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
}

document.addEventListener("turbolinks:load", () => {
  EditorBox.init();
});
