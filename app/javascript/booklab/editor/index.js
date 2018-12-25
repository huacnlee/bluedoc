import { Container, serializer, UI } from 'typine'
import { AttachmentUpload } from "./attachment_upload"
import { Toolbar } from "./toolbar"

class RichEditor extends React.Component {
  constructor(props) {
    super(props);

    if (props.value.trim() === "") {
      props.value = "empty doc";
    }

    let value = serializer.parserToValue(serializer.parserMarkdown(props.value));

    this.state = {
      value: value,
      activeMarkups: [],
      directUploadURL: props.directUploadURL,
      blobURLTemplate: props.blobURLTemplate,
      title: props.title,
      slug: props.slug,
    }

    this.editor = null;
  }

  container = null
  containerRef = React.createRef()

  componentDidMount() {
    this.container = ReactDOM.findDOMNode(this.containerRef.current)
  }

  getEditorContainer = () => {
    return this.container
  }

  setEditor = editor => {
    this.editor = editor
  }

  onChange = (change) => {
    const { format } = this.props;

    this.setState({ value: change.value })

    const xslValue = serializer.parserToXSL(change.value);
    const markdownValue = serializer.parserToMarkdown(xslValue);

    if (format === "markdown") {
      this.props.onChange(markdownValue, null);
    } else {
      const smlValue = JSON.stringify(xslValue)
      this.props.onChange(markdownValue, smlValue);
    }
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

  onMarkupChange = markups => {
    this.setState({ activeMarkups: markups })
  }

  isActiveMarkup = type => {
    const { activeMarkups } = this.state
    return activeMarkups.indexOf(type) >= 0
  }

  // Render the editor.
  render() {
    const { value, title, slug } = this.state;
    const { directUploadURL, blobURLTemplate } = this.state;
    const slugPrefix = window.location.href.split("/docs")[0] + "/docs/";

    const service = {
      imageUpload(file) {
        return new Promise((resolve, reject) => {
          const upload = new AttachmentUpload(file, directUploadURL, blobURLTemplate, (url) => {
            return resolve(url)
          })
          upload.start()
        })
      },
      attachmentUpload(file) {
        return new Promise((resolve, reject) => {
          const upload = new AttachmentUpload(file, directUploadURL, blobURLTemplate, (url) => {
            return resolve(url)
          })
          upload.start()
        })
      },
    }

    return <div>
      <Toolbar value={this.state.value} editor={this.editor} container={this} />
      <div className="editor-bg" ref={this.containerRef}>
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
          <div className="editor-text markdown-body">
            <Container
              value={this.state.value}
              onChange={this.onChange}
              getActiveMarkups={this.onMarkupChange}
              getEditor={this.setEditor}
              getEditorContainer={this.getEditorContainer}
              service={service}
             />
          </div>
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
    if (window.editorAutoLockTimer) {
      clearInterval(window.editorAutoLockTimer)
    }

    const saveButton = $(".btn-save");
    const saveURL = saveButton.attr("data-url");
    const lockURL = saveURL + "/lock";

    // unload to unlock doc
    window.addEventListener("beforeunload", () => {
      $.post(lockURL + "?unlock=true");
    })

    const bodyInput = document.getElementsByName("doc[body]")[0];
    const bodySMLInput = document.getElementsByName("doc[body_sml]")[0];
    const editorMessage = $(".editor-message");

    const titleInput = document.getElementsByName("doc[title]")[0];
    const slugInput = document.getElementsByName("doc[slug]")[0];
    const formatInput = document.getElementsByName("doc[format]")[0];

    const editorDiv = document.createElement("div");
    editorDiv.className = "editor-container";

    const onChange = (markdownValue, smlValue) => {
      bodyInput.value = markdownValue;
      if (smlValue) {
        bodySMLInput.value = smlValue;
      }

      if (window.editorAutoSaveTimer) {
        clearTimeout(window.editorAutoSaveTimer);
      }
      window.editorAutoSaveTimer = setTimeout(() => {
        saveButton.trigger("click");
      }, 5000);
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
      const titleInput = document.getElementsByName("doc[title]")[0];
      const bodyInput = document.getElementsByName("doc[body]")[0];

      $.ajax({
        method: "PUT",
        url: saveURL,
        dataType: "JSON",
        data: {
          doc: {
            draft_title: titleInput.value,
            draft_body: bodyInput.value,
          },
        },
        success: (res) => {
          editorMessage.html("<i class='fas fa-check'></i> saved")
          setTimeout(() => editorMessage.fadeOut(), 3000)
        }
      })

      return false;
    });

    window.editorAutoLockTimer = setInterval(() => {
      $.post(lockURL);
    }, 15000);

    $("form").after(editorDiv);
    ReactDOM.render(
      <RichEditor
        onChange={onChange}
        onChangeTitle={onChangeTitle}
        onChangeSlug={onChangeSlug}
        directUploadURL={bodyInput.attributes["data-direct-upload-url"].value}
        blobURLTemplate={bodyInput.attributes["data-blob-url-template"].value}
        title={titleInput.value}
        slug={slugInput.value}
        format={formatInput.value}
        value={bodyInput.value} />,
      editorDiv,
    )
  }
}

document.addEventListener("turbolinks:load", () => {
  EditorBox.init();
});
