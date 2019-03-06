// eslint-disable-next-line import/no-extraneous-dependencies
import { PureComponent } from 'react';

export default class DocItem extends PureComponent {
  onAddClick = () => {
    const { item, onAddItem } = this.props;
    onAddItem && onAddItem(item);
  }

  render() {
    const { item = {}, isNew = false } = this.props;
    const { exist = false, title = '', url = '' } = item;
    if (exist) return null;
    if (isNew) {
      return (
        <div className='doc-item-drageable doc-item new link-gray-dark' onClick={this.onAddClick}>
          <div className="title icon-middle-wrap">
            <i className="fas fa-add" style={{ marginRight: '10px' }}></i>
            {i18n.t('Add a custom item')}
          </div>
        </div>
      );
    }
    return (
      <div className='doc-item-drageable doc-item'>
        <div className="title">{title}</div>
        <div className="slug">{url}</div>
        <div className="opts" onClick={this.onAddClick}>
          <i className="fas fa-add"></i>
        </div>
      </div>
    );
  }
}
