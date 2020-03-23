import React, { Component } from 'react';
import { visitDoc } from './utils';

export default class ListNode extends Component {
  onClick = (e) => {
    e.preventDefault();
    const url = e.currentTarget.getAttribute('href');
    visitDoc(url);

    return false;
  }

  render() {
    const {
      toc, t, onDeleteNode, repository, editMode, currentDocId,
    } = this.props;
    const {
      title, url, docId, id,
    } = toc;
    const active = currentDocId === docId;

    let className = 'toc-item toc-list-item';
    if (active) {
      className += ' active';
    }

    const docURL = `${repository.path}/${url}`;

    return <li className={className}>
      <a className="item-link" onClick={this.onClick} href={docURL}>{title}</a>
      <a className="item-slug" onClick={this.onClick} href={docURL}>{url}</a>
      {editMode
        && <details className="item-more dropdown details-overlay details-reset d-inline-block">
          <summary><i className="fas fa-ellipsis"></i></summary>
          <ul className="dropdown-menu dropdown-menu-sw">
            <li><a href={`${docURL}/edit`} className="dropdown-item">{t('.Edit doc')}</a></li>
            <li className='dropdown-divider'></li>
            <li className='dropdown-item' onClick={() => onDeleteNode({ id })}>{t('.Delete doc')}</li>
          </ul>
        </details>
      }
    </li>;
  }
}
