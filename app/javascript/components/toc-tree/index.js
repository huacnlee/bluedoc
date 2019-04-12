import React, { Component } from 'react';
import { graph } from 'bluedoc/graphql';
import Tree from './tree';
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

class TocTree extends Component {
  state = {
    treeData: [],
    loading: true,
    editMode: false,
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
      console.log(result, params, '保存成功');
    });
  }

  onChange = treeData => this.setState({ treeData })

  toggleEditMode = (e) => {
    e.preventDefault();

    const { editMode } = this.state;

    this.setState({
      editMode
    })

    return false;
  }

  render() {
    const { treeData, editMode } = this.state;
    const { titleBar, abilities, repository, user } = this.props;

    console.log(treeData);
    return (
      <div className="toc-tree">
        {titleBar && (
        <div className="toc-tree-toolbar doc-parents">
          <a className="link-back text-main" href={repository.path}>{repository.name}</a>
          <a className="link-group text-gray-light" href={user.path}>{user.name}</a>
          {abilities.update && (
            <div className="actions">
            <details className="dropdown details-overlay details-reset d-inline-block">
              <summary className="btn-link"><i className="fas fa-more"></i></summary>
              <ul className="dropdown-menu dropdown-menu-sw">
                <li><a href={`${repository.path}/docs/new`} className="dropdown-item">创建新文档</a></li>
                <li className="dropdown-divider"></li>
                <li><a href={`${repository.path}/settings/profile`} className="dropdown-item">知识库设置</a></li>
              </ul>
            </details>
            </div>
          )}
        </div>
        )}

        <Tree
          treeData={treeData}
          editMode={editMode}
          onChange={this.onChange}
          onMoveNode={this.onMoveNode}
        />
      </div>
    );
  }
}

export default TocTree;
