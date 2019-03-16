import { isShow, formatItems } from './utils';

export default class TocList extends React.PureComponent {
  constructor(props) {
    super(props);
    const { items, folders } = formatItems(this.props.items, this.props.currentSlug);

    this.state = {
      items,
      folders,
    };
  }

  handdleFolder = (index) => {
    const { folders } = this.state;
    const folderIndex = folders.findIndex(e => e.id === index);
    folders[folderIndex].foldersStatus = !folders[folderIndex].foldersStatus;
    this.setState({
      folders: [...folders],
    });
  }

  render() {
    const { items = [], folders = [] } = this.state;
    const { currentSlug, withSlug = false, prefix } = this.props;

    return (
      <ul className="toc-items">
        {items.map(({
          title, url, tocPath, depth,
        }, index) => {
          const show = isShow(tocPath, folders);
          const folder = folders.find(e => e.id === index);
          const active = url === currentSlug;
          let linkUrl = url;

          // If url is only slug (not contains "/") and has prefix props, add prefix to url
          if (url && prefix && !url.includes('/')) {
            linkUrl = `${prefix}${url}`;
          }

          return (
            <li
              className={`toc-item ${active ? 'active' : ''} ${show ? '' : 'hidden'}`}
              key={index}
              style={{ marginLeft: `${15 * (depth)}px` }}
            >
              {folder && (
                <i className={`fas fa-arrow ${folder.foldersStatus ? '' : 'folder'}`} onClick={() => this.handdleFolder(index)}/>
              )}
              <a href={linkUrl} className="item-link">{title}</a>
              {withSlug && <a href={linkUrl} className="item-slug">{url}</a>}
            </li>
          );
        })}
      </ul>
    );
  }
}
