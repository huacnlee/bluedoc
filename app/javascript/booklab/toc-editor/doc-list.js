// eslint-disable-next-line import/no-extraneous-dependencies
import { PureComponent } from 'react';
import DocItem from './doc-item';

export default class DocList extends PureComponent {
  filterList = () => {
    const { tocItems, docItems } = this.props;
    return docItems.map((item) => {
      const exist = (tocItems.findIndex(({ url = '', id = '' }) => (url === item.url || id === item.id))) !== -1;
      return { ...item, exist };
    });
  }

  render() {
    const list = this.filterList();
    const { onAddItem } = this.props;
    return (
      <div className="doc-list col-4">
        <DocItem key='doc-new' onAddItem={onAddItem} isNew/>
        {list.map((item, index) => (
          <DocItem key={`item-${index}`} onAddItem={onAddItem} item={item} />
        ))}
      </div>
    );
  }
}
