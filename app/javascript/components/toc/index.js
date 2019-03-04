export default class TocList extends React.PureComponent {
  constructor(props) {
    super(props);
    const { list, folders } = this.initData(this.props);
    this.state = {
      list,
      folders,
    };
  }

  defaultFoldeDepth = 1;

  initData = ({ list }) => {
    const data = JSON.parse(list);
    const prevNodeId = [0];
    const folderNode = [];
    const result = data.map((item, index) => {
      const { depth = 0 } = item;
      if (depth > prevNodeId.length - 1) {
        folderNode.push(prevNodeId[prevNodeId.length - 1]);
        prevNodeId.splice(depth, 0, index);
      } else {
        prevNodeId.splice(depth, prevNodeId.length - depth, index);
      }
      return {
        ...item,
        tocPath: prevNodeId.join('_'),
      };
    });
    return {
      list: result,
      folders: folderNode.map(i => ({
        id: i,
        foldersStatus: result[i].depth > this.defaultFoldeDepth - 1,
      })),
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

  isShow = (path) => {
    const { folders } = this.state;
    const pathNode = path.split('_');
    if (pathNode.length > 1) {
      pathNode.pop();
      return !pathNode.some((item) => {
        const folderNode = folders.find(e => e.id * 1 === item * 1);
        return folderNode ? folderNode.foldersStatus : false;
      });
    }

    return true;
  }

  render() {
    const { list, folders } = this.state;
    const { doc } = this.props;
    console.log(doc, list);
    return (
      <ul className="toc-items">
        {list.map(({
          title, url, tocPath, depth,
        }, index) => {
          const show = this.isShow(tocPath);
          const folder = folders.find(e => e.id === index);
          return show ? (
            <li
              className={`toc-item ${url === doc.slug ? 'active' : ''}`}
              key={index}
              style={{ marginLeft: `${20 * (depth)}px` }}
            >
              {folder && (
                <i className={`fas fa-arrow ${folder.foldersStatus ? '' : 'folder'}`} onClick={() => this.handdleFolder(index)}/>
              )}
              <a href={url}>{title}</a>
            </li>
          ) : null;
        })}
      </ul>
    );
  }
}
