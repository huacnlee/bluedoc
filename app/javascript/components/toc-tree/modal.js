import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import Dialog from 'bluebox/dialog';
import { Icon } from 'bluebox/iconfont';
import { Fetch, updateToc, createToc } from './api';
import { getNewUrl, readAsText } from './utils';

class ConfirmDialog extends Component {
  constructor(props) {
    super(props);

    const { info = {}, type } = props;

    this.state = {
      open: this.props.open,
      fileName: undefined,
      title: type === 'createToc' ? '' : info.title,
      url: type === 'createToc' ? '' : info.url,
      hasInputedSlug: info.url.length > 0,
      randomSlug: Math.random().toString(36).substring(8),
      body: '',
    };

    this.titleRef = React.createRef();
    this.urlRef = React.createRef();
  }

  componentDidMount() {
    window.addEventListener('keydown', this.handleKeyEnter);
  }

  componentWillUnmount() {
    window.removeEventListener('keydown', this.handleKeyEnter);
  }

  handleClose = () => this.setState({ open: false });

  handleKeyEnter = (e) => {
    if (e.keyCode === 13) {
      e.preventDefault();
      this.handleConfirm();
    }
  };

  handleConfirm = () => {
    const { type } = this.props;
    this.setState(
      {
        loading: true,
      },
      () => {
        if (type === 'updateToc') {
          this.handleUpdateToc();
        }
        if (type === 'createToc') {
          this.handleCreateToc();
        }
      },
    );
  };

  // update toc
  handleUpdateToc = () => {
    const { info = {}, onSuccessBack, active } = this.props;
    const title = this.titleRef.current.value;
    const url = this.urlRef.current.value;
    const params = {
      id: info.id,
      title,
      url,
    };
    Fetch({
      api: updateToc,
      params,
      onSuccess: (result) => {
        window.App.notice(this.props.t('.Toc has successfully updated'));
        // 修改当前文档，页面重载， 否则更新treedate数据
        if (active) {
          window.Turbolinks.visit(getNewUrl(url));
        } else {
          onSuccessBack && onSuccessBack({ title, url });
          this.setState({ loading: false }, this.handleClose);
        }
      },
    });
  };

  // create toc inset toc tree
  handleCreateToc = () => {
    const {
      repository,
      info: { id: targetId },
      onSuccessBack,
      active,
      position = 'child',
    } = this.props;
    const { fileName, body } = this.state;
    const title = this.titleRef.current.value;
    const url = this.urlRef.current.value;
    const params = {
      repositoryId: repository.id,
      title,
      targetId,
      url,
      position,
    };
    if (!url) {
      delete params.url;
    }
    if (fileName) {
      params.body = body;
      params.format = 'markdown';
    }
    Fetch({
      api: createToc,
      params,
      onSuccess: (result) => {
        window.App.notice(this.props.t('.Toc has successfully updated'));
        // 修改当前文档，页面重载， 否则更新treedate数据
        if (active) {
          window.Turbolinks.visit(getNewUrl(url));
        } else {
          onSuccessBack && onSuccessBack({ ...result.createToc });
          this.setState({ loading: false }, this.handleClose);
        }
      },
    });
  };

  handleMarkdown = (e) => {
    if (e.target.files && e.target.files.length > 0 && e.target.files[0].size > 0) {
      const file = e.target.files[0];
      const p = readAsText(file);
      p.then(
        (arg) => {
          const title = file.name.split('.')[0];
          const url = App.generateSlugByTitle(this.state.randomSlug, title);
          this.setState({
            fileName: file.name, title, url, body: arg,
          });
        },
        error => App.alert('Invalid Markdown file, can not read it'),
      );
    }
  };

  onTitleChange = (e) => {
    const name = e.currentTarget.value;

    const { hasInputedSlug, randomSlug } = this.state;
    const autoSlug = App.generateSlugByTitle(randomSlug, name);

    if (!hasInputedSlug) {
      this.setState({
        url: autoSlug,
      });
    }
  }

  render() {
    const {
      open, fileName, title = '', url = '',
    } = this.state;
    const {
      title: dialogTitle, t, repository, type, afterClose,
    } = this.props;
    return (
      <Dialog
        open={open}
        title={dialogTitle}
        onClose={this.handleClose}
        afterClose={afterClose}
        actionsEle={[
          <button className="btn" style={{ minWidth: '88px' }} onClick={this.handleClose}>
            {t('.Cancel')}
          </button>,
          <button
            className="btn btn-primary"
            style={{ minWidth: '88px' }}
            onClick={this.handleConfirm}
          >
            {t('.Update')}
          </button>,
        ]}
      >
        <form>
           {type === 'createToc' && (
            <div className="form-group">
              <label className="form-input-file">
                <div className="btn btn-upload mb-2">
                  <div><Icon name="file" /> {t('.Select markdown file')}</div>
                  {fileName && <div className="text-gray mt-1">{fileName}</div>}
                </div>
                <input
                  type="file"
                  className="form-control"
                  accept=".md"
                  onChange={this.handleMarkdown}
                />
              </label>
              <div className="form-text">{t('.Import markdown tips')}</div>
            </div>
           )}
          <div className="form-group">
            <label className="control-label" />
            <input
              className="form-control"
              type="text"
              autoFocus
              onChange={this.onTitleChange}
              defaultValue={title}
              placeholder={t('.Title')}
              ref={this.titleRef}
            />
          </div>
          <div className="form-group mb-button">
            <label className="control-label">{t('.Url')}</label>
            <div className="input-group d-flex">
              <div className="input-group-prepend">
                <div className="input-group-text">{`${repository.path}/`}</div>
              </div>
              <input
                className="form-control"
                type="text"
                defaultValue={url}
                placeholder={'slug'}
                ref={this.urlRef}
              />
            </div>
          </div>
        </form>
      </Dialog>
    );
  }
}

export default function dialog(config) {
  const div = document.createElement('div');
  document.body.appendChild(div);

  let currentConfig = {
    ...config,
    close,
    open: true,
    afterClose: destory.bind(this),
  };

  function close() {
    currentConfig = {
      ...currentConfig,
      open: false,
    };
    render(currentConfig);
  }

  function update(newConfig) {
    currentConfig = {
      ...currentConfig,
      ...newConfig,
    };
    render(currentConfig);
  }

  function destory() {
    const unmountResult = ReactDOM.unmountComponentAtNode(div);
    if (unmountResult && div.parentNode) {
      div.parentNode.removeChild(div);
    }
  }

  function render(props) {
    ReactDOM.render(<ConfirmDialog {...props} />, div);
  }

  render(currentConfig);

  return {
    close,
    update,
  };
}
