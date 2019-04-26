import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import Dialog from 'bluebox/dialog';
import { Fetch, updateToc } from './api';
import { getNewUrl } from './utils';
import { TitleInput, UrlInput, ExternalInput } from './form-unit';

export default class UpdataDialog extends Component {
  constructor(props) {
    super(props);

    const {
      open,
      info: { title, url },
    } = props;

    this.state = {
      open,
      title,
      url,
      // hasInputedSlug: url.length > 0,
      randomSlug: Math.random()
        .toString(36)
        .substring(8),
      body: '',
    };

    this.type = this.getType(props.info);
  }

  componentDidMount() {
    window.addEventListener('keydown', this.handleKeyEnter);
  }

  componentWillUnmount() {
    window.removeEventListener('keydown', this.handleKeyEnter);
  }

  getType = ({ docId, url }) => {
    if (docId === null && url === null) {
      return 'toc';
    }
    if (docId === null) {
      return 'external';
    }
    return 'doc';
  };

  handleClose = () => this.setState({ open: false });

  handleKeyEnter = (e) => {
    if (e.keyCode === 13) {
      e.preventDefault();
      this.handleConfirm();
    }
  };

  handleConfirm = () => this.setState({ loading: true }, this.handleUpdateToc);

  // update toc
  handleUpdateToc = () => {
    const { info = {}, onSuccessBack, active } = this.props;
    const { title, url } = this.state;
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
        if (active && info.url !== url) {
          window.Turbolinks.visit(getNewUrl(url));
        } else {
          onSuccessBack && onSuccessBack({ title, url });
          this.setState({ loading: false }, this.handleClose);
        }
      },
    });
  };

  handleChange = name => e => this.setState({ [name]: e.target.value });

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

  renderForm = () => {
    const { title = '', url = '' } = this.state;
    const { t, repository } = this.props;
    switch (this.type) {
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
    const { open } = this.state;
    const { title: dialogTitle, afterClose } = this.props;
    return (
      <Dialog
        open={open}
        title={dialogTitle}
        onClose={this.handleClose}
        afterClose={afterClose}
        actionsEle={this.renderAction()}
      >
        {this.renderForm()}
      </Dialog>
    );
  }
}
