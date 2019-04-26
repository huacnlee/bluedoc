/* eslint-disable import/no-extraneous-dependencies */
import React, { Component } from 'react';
import Dialog from 'bluebox/dialog';
import { Icon } from 'bluebox/iconfont';
import styled from 'styled-components';
import { Fetch, createToc } from './api';
import { readAsText, getValidParams, getMarkdownTitle } from './utils';

const CardWrap = styled.div`
  display: flex;
  justify-content: space-between;
`;
const Card = styled.div`
  width: 24%;
  text-align: center;
  padding: 10% 3%;
  font-size: 13px;
  cursor: pointer;
  &:hover {
    background: #ebebeb;
  }
`;

export default class CreateDialog extends Component {
  constructor(props) {
    super(props);
    const randomSlug = Math.random()
      .toString(36)
      .substring(8);

    this.state = {
      // normal 正常目录+文本
      // external 外链目录
      // markdown 导入markdown初始化文档
      // toc 纯目录，无文档
      type: '', // ['normal', 'external', 'markdown', 'toc']
      open: props.open,
      fileName: undefined,
      randomSlug,
      params: {
        repositoryId: props.repository.id,
        targetId: props.info.id,
        position: props.position || 'child',
        title: '',
        url: '',
        external: false,
        format: '',
        body: '',
        bodySml: '',
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
    const params = getValidParams(this.state.params);
    Fetch({
      api: createToc,
      params,
      onSuccess: (result) => {
        window.App.notice(this.props.t('.Toc has successfully updated'));
        this.props.onSuccessBack && this.props.onSuccessBack({ ...result.createToc });
        this.setState({ loading: false }, this.handleClose);
      },
    });
  };

  handleMarkdown = (e) => {
    if (e.target.files && e.target.files.length > 0 && e.target.files[0].size > 0) {
      const file = e.target.files[0];
      const p = readAsText(file);
      p.then(
        (arg) => {
          const fileName = file.name.split('.')[0];
          const url = App.generateSlugByTitle(this.state.randomSlug, fileName);
          const title = getMarkdownTitle(arg);
          this.setState({
            fileName: file.name,
            params: {
              ...this.state.params,
              title,
              url,
              body: arg,
            },
          });
        },
        error => App.alert('Invalid Markdown file, can not read it'),
      );
    }
  };

  handleChange = name => e => this.setState({ params: { ...this.state.params, [name]: e.target.value } });

  handleChangeType = type => () => {
    const external = type === 'toc' || type === 'external';
    const format = type === 'markdown' ? 'markdown' : '';
    this.setState({ type, params: { ...this.state.params, external, format } });
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
                  onChange={this.handleChange('url')}
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
                  onChange={this.handleChange('url')}
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
              />
            </div>
            <div className="form-group mb-button">
              <label className="control-label">{t('.External Url')}</label>
              <input
                className="form-control"
                type="text"
                value={url}
                placeholder={'https://bluedoc.io/'}
                onChange={this.handleChange('url')}
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
              />
            </div>
          </form>
        );
      case '':
        return (
          <CardWrap>
            <Card className={'card-box'} onClick={this.handleChangeType('normal')}>
              {t('.normal')}
            </Card>
            <Card className={'card-box'} onClick={this.handleChangeType('markdown')}>
              {t('.markdown')}
            </Card>
            <Card className={'card-box'} onClick={this.handleChangeType('toc')}>
              {t('.toc')}
            </Card>
            <Card className={'card-box'} onClick={this.handleChangeType('external')}>
              {t('.external')}
            </Card>
          </CardWrap>
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
