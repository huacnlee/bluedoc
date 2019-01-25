import { DirectUpload } from "activestorage"

export class AttachmentUpload {
  constructor(file, directUploadUrl, blobUrlTemplate, callback, progress) {
    this.file = file
    this.directUploadUrl = directUploadUrl
    this.blobUrlTemplate = blobUrlTemplate
    this.callback = callback
    this.progress = progress
    this.directUpload = new DirectUpload(file, this.directUploadUrl, this)
  }

  start() {
    this.directUpload.create(this.directUploadDidComplete.bind(this))
  }

  directUploadWillStoreFileWithXHR(xhr) {
    xhr.upload.addEventListener("progress", event => {
      if (this.progress) {
        const percent = event.loaded / event.total * 100
        this.progress(percent);
      }
    })
  }

  directUploadDidComplete(error, attributes) {
    if (error) {
      throw new Error(`Direct upload failed: ${error}`)
    }

    const url = this.createBlobUrl(attributes.key)
    this.callback(url)
  }

  createBlobUrl(blobKey) {
    return this.blobUrlTemplate
      .replace(":id", blobKey)
  }
}
