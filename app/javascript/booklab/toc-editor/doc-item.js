// eslint-disable-next-line import/no-extraneous-dependencies
import React from 'react';
import {
  SortableHandle,
} from 'react-sortable-hoc';

export default class DocItem extends React.Component {
  onAddClick = (e) => {
    e.preventDefault();
    const { index, item } = this.props;
    this.props.onAddItem(index, item);
  }

  render() {
    const { item } = this.props;

    let className = 'doc-item-drageable doc-item clearfix';
    if (item.isNew) {
      className += ' doc-item-new';
    }
    if (item.exist) {
      className += ' doc-item-exist';
    }

    return (
      <div className={className}>
      { item.isNew === true && (
        <div className="title">Add a custom item</div>
      )}

      { item.isNew !== true && (
        <div className="title">{item.title}</div>
      )}
        <div className="slug">{item.url}</div>
        <div className="opts">
          <a href="#" className="btn-add" onClick={this.onAddClick}><i className="fas fa-add"></i></a>
        </div>
      </div>
    );
  }
}
