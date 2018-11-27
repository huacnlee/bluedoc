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
              onChange={this.onChangeTitle}
              className="editor-title-text" />
          </div>
          <div className="editor-slug">
            <input
              type="text"
              value={slug}
              placeholder="Set Doc slug in here..."
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

export default MarkdownEditor
