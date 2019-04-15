import React, { Component } from 'react';

export default class ListNode extends Component {
  render() {
    const { toc, t, onDeleteNode, repository, editMode, currentDocId } = this.props;
    const { title, url, docId, id } = toc;
    const active = currentDocId == docId;

    let className = "toc-item toc-list-item";
    if (active) {
      className += " active";
    }

    const docURL = repository.path + "/" + url;

    return <li className={className}>
      <a className="item-link" href={docURL}>{title}</a>
      <a className="item-slug" href={docURL}>{url}</a>
      {editMode &&
        <details className="item-more dropdown details-overlay details-reset d-inline-block">
          <summary className="btn-link"><i className="fas fa-ellipsis"></i></summary>
          <ul className="dropdown-menu dropdown-menu-sw">
            <li><a href={`${docURL}/edit`} className="dropdown-item">{t(".Edit doc")}</a></li>
            <li className='dropdown-divider'></li>
            <li className='dropdown-item' onClick={() => onDeleteNode({ id })}>{t(".Delete doc")}</li>
          </ul>
        </details>
      }
    </li>
  }
}