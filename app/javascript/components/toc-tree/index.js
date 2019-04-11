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

  render() {
    const { treeData } = this.state;
    console.log(treeData);
    return (
      <Tree
        treeData={treeData}
        onChange={this.onChange}
        onMoveNode={this.onMoveNode}
      />
    );
  }
}

export default TocTree;
