import RichEditor from './rich-editor';
import DocSetting from './doc-setting';

class EditorBox {
  static init() {
    const editorEls = document.getElementsByClassName('bluedoc-editor');
    if (editorEls.length == 0) {
      return;
    }

    // clean auto save
    if (window.editorAutoLockTimer) {
      clearInterval(window.editorAutoLockTimer);
    }

    const saveButton = $('.btn-save');
    let saveURL = saveButton.attr('data-url');
    let lockURL = `${saveURL}/lock`;

    // unload to unlock doc
    window.addEventListener('beforeunload', () => {
      $.post(`${lockURL}?unlock=true`);
    });

    const bodyInput = document.getElementsByName('doc[body]')[0];
    const bodySMLInput = document.getElementsByName('doc[body_sml]')[0];
    const editorMessage = $('.editor-message');

    const titleInput = document.getElementsByName('doc[title]')[0];
    const formatInput = document.getElementsByName('doc[format]')[0];

    const onChange = (markdownValue, smlValue) => {
      bodyInput.value = markdownValue;
      if (smlValue) {
        // just change format to sml for publish
        formatInput.value = 'sml';
        bodySMLInput.value = smlValue;
      }

      if (window.editorAutoSaveTimer) {
        clearTimeout(window.editorAutoSaveTimer);
      }
      window.editorAutoSaveTimer = setTimeout(() => {
        saveButton.trigger('click');
      }, 5000);
    };

    const onChangeTitle = (value) => {
      titleInput.value = value;
    };

    const onChangeSettings = (res) => {
      saveURL = res.saveURL;
      lockURL = `${saveURL}/lock`;
      const pageURL = `${saveURL}/edit`;
      window.history.pushState({}, titleInput.value, pageURL);
      document.getElementById('doc-form').setAttribute('action', saveURL);
      $('.doc-link').attr('href', saveURL);
    };

    if ($('#doc-lock-box').length > 0) {
      return;
    }

    // Save button
    saveButton.click((e) => {
      const $btn = $(e.currentTarget);
      editorMessage.show();
      editorMessage.html("<i class='fas fa-clock'></i> saving...");
      const titleInput = document.getElementsByName('doc[title]')[0];
      const bodyInput = document.getElementsByName('doc[body]')[0];

      const docParam = {
        draft_title: titleInput.value,
        draft_body: bodyInput.value,
      };

      if (formatInput.value === 'sml') {
        docParam.draft_body_sml = bodySMLInput.value;
      }

      $.ajax({
        method: 'PUT',
        url: saveURL,
        dataType: 'JSON',
        data: {
          doc: docParam,
        },
        success: (res) => {
          editorMessage.html("<i class='fas fa-check'></i> saved");
          setTimeout(() => editorMessage.fadeOut(), 3000);
        },
      });

      return false;
    });

    window.editorAutoLockTimer = setInterval(() => {
      $.post(lockURL);
    }, 15000);

    const value = formatInput.value === 'markdown' ? bodyInput.value : bodySMLInput.value;

    ReactDOM.render(
      <RichEditor
        onChange={onChange}
        onChangeTitle={onChangeTitle}
        directUploadURL={bodyInput.attributes['data-direct-upload-url'].value}
        blobURLTemplate={bodyInput.attributes['data-blob-url-template'].value}
        plantumlServiceHost={bodyInput.attributes['data-plantuml-service-host'].value}
        mathJaxServiceHost={bodyInput.attributes['data-mathjax-service-host'].value}
        title={titleInput.value}
        format={formatInput.value}
        value={value} />,
      document.querySelector('.editor-container'),
    );

    ReactDOM.render(
      <DocSetting
        saveURL={saveURL}
        onChange={onChangeSettings}
        repositoryURL={bodyInput.attributes['data-repository-url'].value}
        slug={bodyInput.attributes['data-slug'].value} />,
      document.querySelector('.btn-doc-info-box'),
    );
  }
}

document.addEventListener('turbolinks:load', () => {
  EditorBox.init();
});
