import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import Dialog from 'bluebox/dialog';
import { Fetch, updateToc } from './api';
import { getNewUrl } from './utils';

export default class UpdataDialog extends Component {
  constructor(props) {
    super(props);

    const {
      info: { title, url },
    } = props;

    this.state = {
      open: this.props.open,
      fileName: undefined,
      title,
      url,
      hasInputedSlug: url.length > 0,
      randomSlug: Math.random()
        .toString(36)
        .substring(8),
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

  handleConfirm = () => this.setState({ loading: true }, this.handleUpdateToc);

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

  render() {
    const { open, title = '', url = '' } = this.state;
    const {
      title: dialogTitle, t, repository, afterClose,
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
                value={url}
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
