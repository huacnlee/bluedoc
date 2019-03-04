import { isShow, formatList } from './utils';

export default class TocList extends React.PureComponent {
  constructor(props) {
    super(props);
    const { list, folders } = formatList(this.props.list);
    this.state = {
      list,
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
    const { list, folders } = this.state;
    const { doc = {}, withSlug = false } = this.props;
    return (
      <ul className="toc-items">
        {list.map(({
          title, url, tocPath, depth,
        }, index) => {
          const show = isShow(tocPath, folders);
          const folder = folders.find(e => e.id === index);
          const active = withSlug && url === doc.slug;
          return (
            <li
              className={`toc-item ${active ? 'active' : ''} ${show ? '' : 'hidden'}`}
              key={index}
              style={{ marginLeft: `${20 * (depth)}px` }}
            >
              {folder && (
                <i className={`fas fa-arrow ${folder.foldersStatus ? '' : 'folder'}`} onClick={() => this.handdleFolder(index)}/>
              )}
              <a href={url} className="item-link">{title}</a>
              {withSlug && <a href={url} className="item-slug">{url}</a>}
            </li>
          );
        })}
      </ul>
    );
  }
}
