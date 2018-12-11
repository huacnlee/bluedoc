import ImageUpload from './image_upload'
import Dropzone from 'react-dropzone'

class ImageDropzone extends React.Component {
  constructor(props) {
    super(props);
  }

  onDrop = (acceptedFiles, rejectedFiles) => {
    const { editor, directUploadUrl, blobUrlTemplate  } = this.props;

    acceptedFiles.forEach(file => {
      const uploader = new ImageUpload(file, directUploadUrl, blobUrlTemplate, (url) => {
        let imageLine = "![]("+ url +")\n";
        if (editor.value.trim().length !== 0) {
          imageLine = "\n" + imageLine;
        }
        editor.value = editor.value + imageLine;
      })
      uploader.start();
    });
  }

  render() {
    return (
      <Dropzone onDrop={this.onDrop}  accept=".gif,.jpeg,.jpg,.png">
        {({getRootProps, getInputProps, isDragActive}) => {
          let className = "dropzone";
          if (isDragActive) {
            className += "dropzone dropzone-active";
          }

          return (
            <div
              {...getRootProps()}
              className={className}
            >
              <input {...getInputProps()} />
              {
                isDragActive ?
                  <div><i className="fas fa-text-image"></i> Drop files here...</div> :
                  <div><i className="fas fa-text-image"></i> Try dropping some files here, or click to select files to upload.</div>
              }
            </div>
          )
        }}
      </Dropzone>
    )
  }
}


export default class CommentForm {
  static init() {
    if ($(".new_comment").length === 0) {
      return;
    }

    const $form = $(".new_comment");

    // close reply
    $(".in-reply-info", $form).on("click", ".close", (e) => {
      const $info = $(e.delegateTarget);
      $info.html("");
      $("input[name='comment[parent_id]']", $form).val("");
      return false;
    });


    $("markdown-image-upload").each((idx, container) => {
      const editor = document.getElementById(container.getAttribute("for"));
      const directUploadUrl = editor.getAttribute("data-direct-upload-url");
      const blobUrlTemplate = editor.getAttribute("data-blob-url-template");

      ReactDOM.render(
        <ImageDropzone editor={editor} directUploadUrl={directUploadUrl} blobUrlTemplate={blobUrlTemplate}></ImageDropzone>
        ,container
      )
    })

  }
}