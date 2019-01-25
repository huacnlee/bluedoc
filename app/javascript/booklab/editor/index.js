import { Container, serializer, UI } from 'typine'
import { AttachmentUpload } from "./attachment-upload"
import { Toolbar } from "./toolbar"
import { DocSetting } from "./doc-setting"

const defaultSML = '["root",["p",["span",{"t":1},["span",{"t":0},""]]]]';

class RichEditor extends React.Component {
  constructor(props) {
    super(props);
    let value;

    if (props.format === "markdown") {
      value = serializer.parserToValue(serializer.parserMarkdown(props.value));
    } else {
      value = serializer.parserToValue(JSON.parse(props.value || defaultSML));
    }

    this.state = {
      value: value,
      activeMarkups: [],
      title: props.title,
    }

    const { directUploadURL, blobURLTemplate } = this.props;

    this.attachmentService = {
      imageUpload(file, onProgress) {
        return new Promise((resolve, reject) => {
          const upload = new AttachmentUpload(file, directUploadURL, blobURLTemplate, (url) => {
            return resolve(url)
          }, onProgress)
          upload.start()
        })
      },
      attachmentUpload(file, onProgress) {
        return new Promise((resolve, reject) => {
          const upload = new AttachmentUpload(file, directUploadURL, blobURLTemplate, (url) => {
            return resolve(url)
          }, onProgress)
          upload.start()
        })
      },
      videoUpload(file, onProgress) {
        return new Promise((resolve, reject) => {
          const upload = new AttachmentUpload(file, directUploadURL, blobURLTemplate, (url) => {
            return resolve(url)
          }, onProgress)
          upload.start()
        })
      },
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

    const smlValue = JSON.stringify(xslValue)
    this.props.onChange(markdownValue, smlValue);
  }

  onChangeTitle = (e) => {
    const newTitle = e.target.value
    this.props.onChangeTitle(newTitle)
    this.setState({ title: newTitle })
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
    let { value, title } = this.state;

    // change "New Document" as placeholder
    let placeholder = "Document title";
    if (title.trim() === "New Document") {
      placeholder = "New Document";
      title = "";
    }

    return <React.Fragment>
      <Toolbar value={this.state.value} editor={this.editor} container={this} />
      <div className="editor-bg" ref={this.containerRef}>
        <div className="editor-box">
          <div className="editor-title">
            <input
              type="text"
              value={title}
              placeholder={placeholder}
              onChange={this.onChangeTitle}
              className="editor-title-text" />
          </div>
          <div className="editor-text markdown-body">
            <Container
              value={this.state.value}
              onChange={this.onChange}
              getActiveMarkups={this.onMarkupChange}
              getEditor={this.setEditor}
              getEditorContainer={this.getEditorContainer}
              service={this.attachmentService}
              plantumlServiceHost={this.props.plantumlServiceHost}
              mathJaxServiceHost={this.props.mathJaxServiceHost}
             />
          </div>
        </div>
      </div>
    </React.Fragment>
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
    let saveURL = saveButton.attr("data-url");
    let lockURL = saveURL + "/lock";

    // unload to unlock doc
    window.addEventListener("beforeunload", () => {
      $.post(lockURL + "?unlock=true");
    })

    const bodyInput = document.getElementsByName("doc[body]")[0];
    const bodySMLInput = document.getElementsByName("doc[body_sml]")[0];
    const editorMessage = $(".editor-message");

    const titleInput = document.getElementsByName("doc[title]")[0];
    const formatInput = document.getElementsByName("doc[format]")[0];

    const onChange = (markdownValue, smlValue) => {
      bodyInput.value = markdownValue;
      if (smlValue) {
        // just change format to sml for publish
        formatInput.value = "sml";
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

    const onChangeSettings = (res) => {
      saveURL = res.saveURL;
      lockURL = saveURL + "/lock";
      const pageURL = saveURL + "/edit";
      window.history.pushState({}, titleInput.value, pageURL);
      document.getElementById("doc-form").setAttribute("action", saveURL);
      $(".doc-link").attr("href", saveURL);
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

      const docParam = {
        draft_title: titleInput.value,
        draft_body: bodyInput.value,
      }

      if (formatInput.value === "sml") {
        docParam["draft_body_sml"] = bodySMLInput.value;
      }

      $.ajax({
        method: "PUT",
        url: saveURL,
        dataType: "JSON",
        data: {
          doc: docParam,
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

    const value = formatInput.value === "markdown" ? bodyInput.value : bodySMLInput.value;

    ReactDOM.render(
      <RichEditor
        onChange={onChange}
        onChangeTitle={onChangeTitle}
        directUploadURL={bodyInput.attributes["data-direct-upload-url"].value}
        blobURLTemplate={bodyInput.attributes["data-blob-url-template"].value}
        plantumlServiceHost={bodyInput.attributes["data-plantuml-service-host"].value}
        mathJaxServiceHost={bodyInput.attributes["data-mathjax-service-host"].value}
        title={titleInput.value}
        format={formatInput.value}
        value={value} />,
      document.querySelector(".editor-container")
    )

    ReactDOM.render(
      <DocSetting
        saveURL={saveURL}
        onChange={onChangeSettings}
        repositoryURL={bodyInput.attributes["data-repository-url"].value}
        slug={bodyInput.attributes["data-slug"].value} />,
      document.querySelector(".btn-doc-info-box")
    )
  }
}

document.addEventListener("turbolinks:load", () => {
  EditorBox.init();
});
