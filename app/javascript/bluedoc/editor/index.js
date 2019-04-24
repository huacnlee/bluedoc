import RichEditor from './rich-editor';
import DocSetting from './doc-setting';

class EditorBox {
  static init() {
    const editorEls = document.querySelectorAll('.bluedoc-editor');
    if (editorEls.length === 0) {
      return;
    }

    // clean auto save
    if (window.editorAutoLockTimer) {
      clearInterval(window.editorAutoLockTimer);
    }

    const saveButton = $('.btn-save');
    const saveURL = saveButton.attr('data-url');
    let lockURL = `${saveURL}/lock`;

    // unload to unlock doc
    window.addEventListener('beforeunload', () => {
      $.post(`${lockURL}?unlock=true`);
    });
    // command or ctrl + s to sava doc
    window.addEventListener('keydown', (e) => {
      if (e.keyCode === 83 && (navigator.platform.match('Mac') ? e.metaKey : e.ctrlKey)) {
        e.preventDefault();
        handleSave();
      }
      // safair command + [,]
      // Prevent browser history from going forward or backward
      if ((e.keyCode === 219 || e.keyCode === 221) && e.metaKey) {
        e.preventDefault();
      }
    }, false);

    const bodyInput = document.getElementsByName('doc[body]')[0];
    const bodySMLInput = document.getElementsByName('doc[body_sml]')[0];
    const editorMessage = $('.editor-message');

    const titleInput = document.getElementsByName('doc[title]')[0];
    const formatInput = document.getElementsByName('doc[format]')[0];

    const handleSave = () => {
      editorMessage.show();
      editorMessage.html("<i class='fas fa-clock'></i> saving...");
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
      if (window.editorAutoSaveTimer) {
        clearTimeout(window.editorAutoSaveTimer);
      }
    };

    const autoSave = () => {
      if (window.editorAutoSaveTimer) {
        clearTimeout(window.editorAutoSaveTimer);
      }
      window.editorAutoSaveTimer = setTimeout(() => {
        handleSave();
      }, 5000);
    };

    const onChange = (markdownValue, smlValue) => {
      bodyInput.value = markdownValue;
      if (smlValue) {
        // just change format to sml for publish
        formatInput.value = 'sml';
        bodySMLInput.value = smlValue;
      }
      autoSave();
    };

    const onChangeTitle = (value) => {
      titleInput.value = value;
    };

    const onChangeSettings = (res) => {
      const newSaveURL = res.saveURL;
      lockURL = `${newSaveURL}/lock`;
      const pageURL = `${newSaveURL}/edit`;
      window.history.pushState({}, titleInput.value, pageURL);
      document.getElementById('doc-form').setAttribute('action', newSaveURL);
      $('.doc-link').attr('href', newSaveURL);
    };

    if ($('#doc-lock-box').length > 0) {
      return;
    }

    // Save button
    saveButton.click(handleSave);

    window.editorAutoLockTimer = setInterval(() => {
      $.post(lockURL);
    }, 15000);

    const value = formatInput.value === 'markdown' ? bodyInput.value : bodySMLInput.value;

    ReactDOM.render(
      <RichEditor
        onChange={onChange}
        onChangeTitle={onChangeTitle}
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
