import { sortableContainer } from 'react-sortable-hoc';
import { graph } from 'bluedoc/graphql';
// import 'react-sortable-tree/style.css';
import SortableTree from 'react-sortable-tree';
import FileExplorerTheme from 'react-sortable-tree-theme-minimal';


import {
  getTreeFromFlatData,
} from './utils';
import Item from './item';

const getTocList = graph(`
  query (@autodeclare) {
    repositoryTocs(repositoryId: $repositoryId) {
      id,
      docId,
      title,
      url,
      parentId,
      depth
    }
  }
`);

const moveTocList = graph(`
  mutation (@autodeclare) {
    moveToc(id: $id, targetId: $targetId, position: $position )
  }
`);

const SortableContainer = sortableContainer(
  ({ children }) => <ul className={'toc-items'}>{children}</ul>,
);

export default class TocList extends React.PureComponent {
  constructor(props) {
    super(props);
    this.sorting = false;
    this.state = {
      items: [],
      folders: [],
      loading: true,
    };
  }

  componentDidMount() {
    this.getTocList();
  }

  // fetch Toc List
  getTocList = () => {
    const { repositoryId } = this.props;
    getTocList({ repositoryId }).then((result) => {
      this.setState({
        items: getTreeFromFlatData({ flatData: result.repositoryTocs, rootKey: null }),
        loading: false,
      });
    }).catch((errors) => {
      App.alert(errors);
    });
  }

  getNodeByPath = ({ treeData, path }) => {
    let result = null;
    path.forEach((path, idx) => {
      result = treeData[path - idx];
    });
    return result;
  }

  onMoveNode = (data) => {
    const {
      node, nextPath, treeData,
    } = data;

    const len = nextPath.length;
    const params = {
      id: node.id,
      position: 'right',
      targetId: null,
    };
    // 插在之前
    if (len === 1 && nextPath[0] === 0) {
      params.position = 'left';
      params.targetId = treeData[1].id;
    // 插入子集
    } else if (len > 1 && (nextPath[len - 1] - nextPath[len - 2] === 1)) {
      const targetPath = nextPath.slice(0, len - 1);
      params.position = 'child';
      params.targetId = this.getNodeByPath({ treeData, path: targetPath }).id;
    // 插在之后
    } else {
      const targetPath = [...nextPath];
      targetPath[len - 1] -= 1;
      params.targetId = this.getNodeByPath({ treeData, path: targetPath }).id;
    }
    moveTocList(params).then((result) => {
      console.log(result, params, '保存成功');
    });
  }

  onChange = (treeData) => {
    this.prevTreeData = this.state.items;
    this.setState({ items: treeData });
  }

  render() {
    const { items = [] } = this.state;
    return (
      <div style={{ height: 300 }}>
        <SortableTree
          treeData={items}
          onChange={this.onChange}
          onMoveNode={this.onMoveNode}
          theme={FileExplorerTheme}
        />
      </div>
    );
  }
}
