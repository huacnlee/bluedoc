/* eslint-disable import/no-extraneous-dependencies */
import React, { Component } from 'react';
import Dialog from 'bluebox/dialog';
import Tab from 'bluebox/tab';
import { Fetch, createToc } from './api';
import { readAsText, getValidParams, getMarkdownTitle } from './utils';
import {
  TitleInput, UrlInput, MarkdownInput, ExternalInput,
} from './form-unit';
// doc 正常目录+文本
// external 外链目录
// markdown 导入markdown初始化文档
// toc 纯目录，无文档
const types = ['toc', 'doc', 'markdown', 'external'];

export default class CreateDialog extends Component {
  constructor(props) {
    super(props);

    const {
      open, repository, t, info, position = 'child',
    } = props;
    const randomSlug = Math.random()
      .toString(36)
      .substring(8);

    this.state = {
      // normal 正常目录+文本
      // external 外链目录
      // markdown 导入markdown初始化文档
      // toc 纯目录，无文档
      type: 'toc',
      open,
      fileName: undefined,
      randomSlug,
      params: {
        repositoryId: repository.id,
        targetId: info.id,
        position,
        title: '',
        url: '',
        external: false,
        format: '',
        body: '',
        bodySml: '',
      },
    };

    this.items = types.map(type => t(`.${type}`));
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

  handleChangeType = (index) => {
    const type = types[index];
    if (type === this.state.type) return;
    const external = type === 'toc' || type === 'external';
    const format = type === 'markdown' ? 'markdown' : '';
    this.setState({
      type,
      params: {
        ...this.state.params,
        external,
        format,
        url: '',
        title: '',
        body: '',
      },
    });
  };

  renderForm = (type) => {
    const { t, repository } = this.props;
    const {
      fileName,
      params: { title, url },
    } = this.state;
    console.log(type);
    switch (type) {
      case 'doc':
        return (
          <form>
            <TitleInput value={title} t={t} onChange={this.handleChange('title')} />
            <UrlInput
              value={url}
              t={t}
              onChange={this.handleChange('url')}
              prefix={repository.path}
            />
          </form>
        );
      case 'markdown':
        return (
          <form>
            <MarkdownInput value={fileName} t={t} onChange={this.handleMarkdown} />
            <TitleInput value={title} t={t} onChange={this.handleChange('title')} />
            <UrlInput
              value={url}
              t={t}
              onChange={this.handleChange('url')}
              prefix={repository.path}
            />
          </form>
        );
      case 'external':
        return (
          <form>
            <TitleInput value={title} t={t} onChange={this.handleChange('title')} />
            <ExternalInput value={url} t={t} onChange={this.handleChange('url')} />
          </form>
        );
      case 'toc':
        return (
          <form>
            <TitleInput value={title} t={t} onChange={this.handleChange('title')} />
          </form>
        );
      default:
        return null;
    }
  };

  renderAction = () => [
    <button className="btn" style={{ minWidth: '88px' }} onClick={this.handleClose}>
      {this.props.t('.Cancel')}
    </button>,
    <button className="btn btn-primary" style={{ minWidth: '88px' }} onClick={this.handleConfirm}>
      {this.props.t('.Update')}
    </button>,
  ];

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
        <Tab items={this.items} onSelect={this.handleChangeType} />
        {this.renderForm(type)}
      </Dialog>
    );
  }
}
