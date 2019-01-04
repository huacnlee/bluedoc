// eslint-disable-next-line import/no-extraneous-dependencies
import React from 'react';
import { SortableElement } from 'react-sortable-hoc';
import cn from 'classnames';

class TocItem extends React.PureComponent {
  constructor(props) {
    super(props);
    this.state = {
      canEdit: false,
    };
  }

  componentWillReceiveProps(nextProps) {
    const { autoFocus, active } = nextProps;
    if (active && autoFocus !== this.props.autoFocus) {
      this.setState({ canEdit: true, autoFocus });
    } if (!active) {
      this.setState({ canEdit: false });
    }
  }

  // sync
  onChangeField = (e) => {
    e.preventDefault();
    const input = e.currentTarget;
    const field = input.getAttribute('data-field');
    const { item } = this.props;
    this.props.onChangeItem({
      index: item.index,
      item: {
        ...item,
        [field]: input.value,
      },
    });
  }

  onKeyDown = (e) => {
    if (e.keyCode === 13 || e.keyCode === 27) {
      // enter
      e.preventDefault();
      this.setState({ canEdit: false }, () => this.props.onChangeItem({ memory: true }));
    }
  }

  onSelectItem = () => {
    this.props.onSelectItem(this.props.item.index);
  }

  handelFolder = () => {
    const { item, onChangeItem } = this.props;
    onChangeItem({
      index: item.index,
      item: {
        ...item,
        folder: !item.folder,
      },
    });
  }

  handleEdit = () => this.setState({ canEdit: true })

  handelDoneEdit = () => this.setState({
    anEdit: false,
  }, () => this.props.onChangeItem({ memory: true }))

  render() {
    const {
      item: {
        url, title, depth, showFolder = false, folder, id,
      }, active,
    } = this.props;
    return (
      <div
        className={cn('toc-edit-item', { active })}
        onClick={this.onSelectItem}
        style={{ marginLeft: `${20 * depth}px` }}
      >
        <div onClick={this.handelFolder} className={cn('folder', { rotate: folder }, { show: showFolder })}>
          <i class="fas fa-caret"></i>
        </div>
        {/* show && edit */}
        {this.state.canEdit ? (
          <form className={'cell-wrap'}>
            <input
              type="text"
              onChange={this.onChangeField}
              onKeyDown={this.onKeyDown}
              data-field="title"
              placeholder="title"
              className="form-edit title"
              value={title}
              autoFocus
            />
            <input
              type="text"
              onChange={this.onChangeField}
              onKeyDown={this.onKeyDown}
              data-field="url"
              placeholder="url"
              className="form-edit slug"
              value={url}
              readOnly={!!id}
            />
            <i className="fas fa-check btn-action btn-ok" onClick={this.handelDoneEdit}></i>
          </form>
        ) : (
          <div className="cell-wrap">
            <span className="title">{title || 'title'}</span>
            <span className="slug">{url || 'url'}</span>
            <i className="fas fa-pencil btn-action btn-edit" onClick={this.handleEdit}></i>
          </div>
        )}
      </div>
    );
  }
}

export default SortableElement(TocItem);
