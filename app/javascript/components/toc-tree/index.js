import React, { Component } from 'react';
import { graph } from 'bluedoc/graphql';
import Tree from './tree';
import ContentLoader from "react-content-loader"
import {
  getTreeFromFlatData,
} from './utils';


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

const deleteToc = graph(`
  mutation (@autodeclare) {
    deleteToc(id: $id)
  }
`);

class TocTree extends Component {
  constructor(props) {
    super(props);

    const { readonly, abilities } = props;

    this.state = {
      treeData: [],
      loading: true,
      editMode: !readonly && abilities.update,
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
        treeData: getTreeFromFlatData({ flatData: result.repositoryTocs, rootKey: null }),
        loading: false,
      });
    }).catch((errors) => {
      App.alert(errors);
    });
  }

  onMoveNode = (data) => {
    const {
      targetId, dragId, position,
    } = data;

    const params = {
      id: dragId,
      position,
      targetId,
    };
    moveTocList(params).then((result) => {
      console.log(result, params, '排序成功');
    });
  }

  onDeleteNode = (params) => {
    if (!confirm(this.t(".Are you sure to delete"))) {
      return false;
    }

    deleteToc(params).then((result) => {
      App.notice(this.t(".Toc has successfully deleted"));
      // FIXME: 从 this.state.treeData 里面删除此项，而不是 getTocList
      this.getTocList();
    });
  }

  t = (key) => {
    if (key.startsWith('.')) {
      return i18n.t(`toc-tree${key}`);
    }
    return i18n.t(key);
  }

  onChange = treeData => this.setState({ treeData })

  toggleEditMode = (e) => {
    e.preventDefault();

    const { editMode } = this.state;

    this.setState({
      editMode,
    });

    return false;
  }

  render() {
    const { loading, treeData, editMode } = this.state;
    const {
      titleBar, abilities, repository, user, currentDocId,
    } = this.props;

    return (
      <div className="toc-tree" data-edit-mode={editMode}>
        {titleBar && (
        <div className="toc-tree-toolbar doc-parents">
          <a className="link-back text-main" href={repository.path}>{repository.name}</a>
          <a className="link-group text-gray-light" href={user.path}>{user.name}</a>
          {abilities.update && (
            <div className="actions">
            <details data-turbolinks={false} className="dropdown details-overlay details-reset d-inline-block">
              <summary className="btn-link"><i className="fas fa-more"></i></summary>
              <ul className="dropdown-menu dropdown-menu-sw">
                <li><a href={`${repository.path}/docs/new`} className="dropdown-item">{this.t(".Create Doc")}</a></li>
                <li className="dropdown-divider"></li>
                <li><a href={`${repository.path}/settings/profile`} className="dropdown-item">{this.t(".Repository Settings")}</a></li>
              </ul>
            </details>
            </div>
          )}
        </div>
        )}

        {loading && (
          <TreeLoader />
        )}
        {!loading && (
          <Tree
          treeData={treeData}
          editMode={editMode}
          onChange={this.onChange}
          onMoveNode={this.onMoveNode}
          onDeleteNode={this.onDeleteNode}
          repository={repository}
          currentDocId={currentDocId}
         />
        )}
      </div>
    );
  }
}

const TreeLoader = () => (
  <div style={{ width: "300px", height: "220px" }}>
  <ContentLoader
    height={220}
    width={300}
    speed={2}
    primaryColor="#f3f3f3"
    secondaryColor="#ecebeb"
  >
    <rect x="10" y="15" rx="4" ry="4" width="117" height="6" />
    <rect x="10" y="39" rx="3" ry="3" width="85" height="6" />
    <rect x="24" y="63" rx="3" ry="3" width="130" height="6" />
    <rect x="24" y="87" rx="3" ry="3" width="100" height="6" />
    <rect x="10" y="111" rx="3" ry="3" width="69" height="6" />
    <rect x="10" y="135" rx="3" ry="3" width="80" height="6" />
    <rect x="24" y="159" rx="3" ry="3" width="140" height="6" />
    <rect x="38" y="183" rx="3" ry="3" width="140" height="6" />
    <rect x="10" y="207" rx="3" ry="3" width="100" height="6" />
  </ContentLoader>
  </div>
)

export default TocTree;
