import { DirectUpload } from 'activestorage';

export default class AttachmentUpload {
  constructor(file, directUploadUrl, blobUrlTemplate, callback, progress) {
    this.file = file;
    this.directUploadUrl = directUploadUrl;
    this.blobUrlTemplate = blobUrlTemplate;
    this.callback = callback;
    this.progress = progress;
    this.directUpload = new DirectUpload(file, this.directUploadUrl, this);
  }

  start() {
    this.directUpload.create(this.directUploadDidComplete.bind(this));
  }

  directUploadWillStoreFileWithXHR(xhr) {
    const { progress } = this;
    let lastPercent = 0;
    xhr.upload.addEventListener('progress', (event) => {
      if (progress) {
        const percent = Math.round(event.loaded / event.total * 100);
        if (percent !== lastPercent) {
          progress(percent);
          lastPercent = percent;
        }
      }
    }, false);
  }

  directUploadDidComplete(error, attributes) {
    if (error) {
      throw new Error(`Direct upload failed: ${error}`);
    }

    const url = this.createBlobUrl(attributes.key);
    this.callback(url);
  }

  createBlobUrl(blobKey) {
    return this.blobUrlTemplate
      .replace(':id', blobKey);
  }
}
