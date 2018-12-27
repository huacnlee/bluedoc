// eslint-disable-next-line import/no-extraneous-dependencies
import { PureComponent } from 'react';

export default class DocItem extends PureComponent {
  onAddClick = () => {
    const { item,onAddItem } = this.props;
    onAddItem && onAddItem(item);
  }

  render() {
    const { item = {}, isNew = false } = this.props;
    const { exist = false, title = '', url = '' } = item;
    if (exist) return null;
    return (
      <div className={`doc-item-drageable doc-item clearfix ${isNew ? 'new' : ''}`}>
        <div className="title">{isNew ? 'Add a custom item' : title}</div>
        <div className="slug">{url}</div>
        <div className="opts" onClick={this.onAddClick}>
          <i className="fas fa-add"></i>
        </div>
      </div>
    );
  }
}
