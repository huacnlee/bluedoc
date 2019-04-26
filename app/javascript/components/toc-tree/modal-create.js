/* eslint-disable import/no-extraneous-dependencies */
import React, { Component } from 'react';
import Dialog from 'bluebox/dialog';
import { Icon } from 'bluebox/iconfont';
import { Fetch, createToc } from './api';
import { getNewUrl, readAsText } from './utils';

export default class CreateDialog extends Component {
  constructor(props) {
    super(props);

    const randomSlug = Math.random()
      .toString(36)
      .substring(8);
    const hasInputedSlug = props.info.url.length > 0;
    this.state = {
      // normal 正常目录+文本
      // external 外链目录
      // markdown 导入markdown初始化文档
      // toc 纯目录，无文档
      type: '', // ['normal', 'external', 'markdown', 'toc']
      open: props.open,
      fileName: undefined,
      randomSlug,
      hasInputedSlug,
      params: {
        title: '',
        url: '',
        external: false,
        format: '',
        body: '',
      },
    };
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

  handleConfirm = () => this.setState({ loading: true }, this.handleCreateToc);

  // create toc inset toc tree
  handleCreateToc = () => {
    const {
      repository,
      info: { id: targetId },
      onSuccessBack,
      active,
      position = 'child',
    } = this.props;
    const {
      type,
      params: { title, url, body },
    } = this.state;
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
    // if (fileName) {
    //   params.body = body;
    //   params.format = 'markdown';
    // }
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
            fileName: file.name,
            title,
            url,
            body: arg,
          });
        },
        error => App.alert('Invalid Markdown file, can not read it'),
      );
    }
  };

  handleChange = name => (e) => {
    const { value } = e.currentTarget.value;
    this.setState({ params: { ...this.state.params, [name]: value } });
  };

  handleChangeType = type => () => this.setState({ type });

  onTitleChange = (e) => {
    const name = e.currentTarget.value;

    const { hasInputedSlug, randomSlug } = this.state;
    const autoSlug = App.generateSlugByTitle(randomSlug, name);

    if (!hasInputedSlug) {
      this.setState({
        url: autoSlug,
      });
    }
  };

  renderForm = (type) => {
    const {
      fileName,
      params: { title, url },
    } = this.state;
    const { t, repository } = this.props;
    switch (type) {
      case 'normal':
        return (
          <form>
            <div className="form-group">
              <label className="control-label">{t('.Title')}</label>
              <input
                className="form-control"
                type="text"
                autoFocus
                onChange={this.handleChange('title')}
                value={title}
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
                  value={url}
                  placeholder={'slug'}
                  onChange={this.handleChange('title')}
                  ref={this.urlRef}
                />
              </div>
            </div>
          </form>
        );
      case 'markdown':
        return (
          <form>
            <div className="form-group">
              <label className="form-input-file">
                <div className="btn btn-upload mb-2">
                  <div>
                    <Icon name="file" /> {t('.Select markdown file')}
                  </div>
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
            <div className="form-group">
              <label className="control-label">{t('.Title')}</label>
              <input
                className="form-control"
                type="text"
                autoFocus
                onChange={this.handleChange('title')}
                value={title}
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
                  value={url}
                  placeholder={'slug'}
                  onChange={this.handleChange('title')}
                  ref={this.urlRef}
                />
              </div>
            </div>
          </form>
        );
      case 'external':
        return (
          <form>
            <div className="form-group">
              <label className="control-label">{t('.Title')}</label>
              <input
                className="form-control"
                type="text"
                autoFocus
                onChange={this.handleChange('title')}
                value={title}
                ref={this.titleRef}
              />
            </div>
            <div className="form-group mb-button">
              <label className="control-label">{t('.External Url')}</label>
              <input
                className="form-control"
                type="text"
                value={url}
                placeholder={'slug'}
                onChange={this.handleChange('title')}
                ref={this.urlRef}
              />
            </div>
          </form>
        );
      case 'toc':
        return (
          <form>
            <div className="form-group">
              <label className="control-label">{t('.Title')}</label>
              <input
                className="form-control"
                type="text"
                autoFocus
                onChange={this.handleChange('title')}
                value={title}
                ref={this.titleRef}
              />
            </div>
          </form>
        );
      case '':
        return (
          <>
            <button
              className={'btn btn-primary btn-full mb-4'}
              onClick={this.handleChangeType('toc')}
            >
              {'toc'}
            </button>
            <button
              className={'btn btn-primary btn-full mb-4'}
              onClick={this.handleChangeType('external')}
            >
              {'external'}
            </button>
            <button
              className={'btn btn-primary btn-full mb-4'}
              onClick={this.handleChangeType('normal')}
            >
              {'normal'}
            </button>
            <button
              className={'btn btn-primary btn-full mb-4'}
              onClick={this.handleChangeType('markdown')}
            >
              {'markdown'}
            </button>
          </>
        );
      default:
        return null;
    }
  };

  renderAction = (type) => {
    const { t } = this.props;
    if (type) {
      return [
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
      ];
    }
    return [];
  };

  render() {
    const { open, type } = this.state;
    const { title: dialogTitle, afterClose } = this.props;
    console.log(type);
    return (
      <Dialog
        open={open}
        title={dialogTitle}
        onClose={this.handleClose}
        afterClose={afterClose}
        maxWidth="sm"
        fullWidth
        actionsEle={this.renderAction(type)}
      >
        {this.renderForm(type)}
      </Dialog>
    );
  }
}
