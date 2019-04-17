
import React, { Component } from 'react';
import ReactDOM from 'react-dom';
import Dialog from 'bluebox/dialog';
import { updateToc, createToc } from './api';
import { getNewUrl } from './utils';

class ConfirmDialog extends Component {
  constructor(props) {
    super(props);

    this.state = {
      open: this.props.open,
    };

    this.titleRef = React.createRef();
    this.urlRef = React.createRef();
  }

  handleClose = () => this.setState({ open: false })

  handleConfirm = () => {
    const { type } = this.props;
    this.setState({
      loading: true,
    }, () => {
      if (type === 'updateToc') {
        this.handleUpdateToc();
      }
      if (type === 'createToc') {
        this.handleCreateToc();
      }
    });
  }


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
    updateToc(params).then((result) => {
      window.App.notice(this.props.t('.Toc has successfully updated'));
      // 修改当前文档，页面重载， 否则更新treedate数据
      if (active) {
        window.Turbolinks.visit(getNewUrl(url));
      } else {
        onSuccessBack && onSuccessBack({ title, url });
        this.setState({ loading: false }, this.handleClose);
      }
    });
  }

  // create toc
  handleCreateToc = () => {
    const {
      repository,
      info: {
        id: targetId,
      }, onSuccessBack, active,
    } = this.props;
    const title = this.titleRef.current.value;
    const url = this.urlRef.current.value;
    const params = {
      repositoryId: repository.id,
      title,
      targetId,
      position: 'child',
    };
    createToc(params).then((result) => {
      window.App.notice(this.props.t('.Toc has successfully updated'));
      // 修改当前文档，页面重载， 否则更新treedate数据
      if (active) {
        window.Turbolinks.visit(getNewUrl(url));
      } else {
        onSuccessBack && onSuccessBack({ ...result.createToc });
        this.setState({ loading: false }, this.handleClose);
      }
    });
  }

  render() {
    const { open } = this.state;
    const {
      info = {}, t, repository, type,
    } = this.props;
    const { url, title } = info;
    return (
      <Dialog
        open={open}
        title={t('.title')}
        onClose={this.handleCLose}
        actionsEle={[
          <button className='btn' onClick={this.handleClose}>{t('.Cancel')}</button>,
          <button className='btn btn-primary' onClick={this.handleConfirm}>{t('.Update')}</button>,
        ]}
      >
        <form>
          <div className='form-group'>
            <label className='control-label'></label>
            <input
              className='form-control'
              type='text'
              defaultValue={type === 'updateToc' ? title : ''}
              placeholder={'title'}
              ref={this.titleRef}
            />
          </div>
          <div className='form-group'>
            <label className='control-label'>{t('.url')}</label>
            <div className='input-group d-flex'>
              <div className='input-group-prepend'>
                <div className='input-group-text'>{`${repository.path}/`}</div>
              </div>
              <input
                className='form-control'
                type='text'
                defaultValue={type === 'updateToc' ? url : ''}
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
    ...config, close, open: true, afterClose: destory.bind(this),
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
    ReactDOM.render(<ConfirmDialog {...props}/>, div);
  }

  render(currentConfig);

  return {
    close,
    update,
  };
}
