import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import Dialog from 'bluebox/dialog';
import { Icon } from 'bluebox/iconfont';
import { Fetch, updateToc, createToc } from './api';
import { getNewUrl, readAsText } from './utils';

class ConfirmDialog extends Component {
  constructor(props) {
    super(props);

    this.state = {
      open: this.props.open,
      fileName: undefined,
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
        arg => this.setState({ fileName: file.name, body: arg }),
        error => console.error(`read md file Failed: ${error}`),
      );
    }
  };

  render() {
    const { open, fileName } = this.state;
    const {
      title: dialogTitle, info = {}, t, repository, type, afterClose,
    } = this.props;
    const { url = '', title = '' } = info;
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
          <div className="form-group">
            <label className="control-label" />
            <input
              className="form-control"
              type="text"
              autoFocus
              defaultValue={type === 'updateToc' ? title : ''}
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
                defaultValue={
                  type === 'updateToc'
                    ? url
                    : Math.random()
                      .toString(36)
                      .substring(8)
                }
                placeholder={'slug'}
                ref={this.urlRef}
              />
            </div>
          </div>
          {type === 'createToc' && (
            <div className="form-group">
              <label className="form-input-file">
                <span className="btn mb-2">
                  {t('.Import markdown file')}
                  {fileName && <span className="text-primary">({fileName})</span>}
                </span>
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
