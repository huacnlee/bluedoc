/* eslint-disable import/no-extraneous-dependencies */
import React, { Component } from 'react';
import ContentLoader from 'react-content-loader';
import { MuiThemeProvider } from '@material-ui/core/styles';
import Switch from '@material-ui/core/Switch';
import theme from 'bluebox/theme';
import Icon from 'bluebox/iconfont';
import update from 'immutability-helper';
import Tree from './tree';
import ListNode from './ListNode';
import dialog from './modal';

import {
  getTreeFromFlatData,
} from './utils';
import { getTocList, moveTocList, deleteToc } from './api';

class TocTree extends Component {
  constructor(props) {
    super(props);
    const {
      // type : ['center', 'side']
      abilities, repository, tocs, currentDocId, type,
    } = props;
    const viewMode = repository.has_toc ? 'tree' : 'list';
    const treeData = viewMode === 'tree' ? getTreeFromFlatData({
      flatData: tocs || [],
      rootKey: null,
      active: currentDocId,
    }) : tocs;
    const canEdit = abilities.update;
    // 只有在文档页面侧边并且有权限 默认可编辑
    const editMode = canEdit && type === 'side';
    this.state = {
      loading: false,
      treeData,
      canEdit,
      editMode,
      viewMode,
    };
  }

  componentDidMount() {
    const { tocs } = this.props;
    if (!tocs) {
      this.getTocList();
    }
  }

  // fetch Toc List
  getTocList = () => {
    const { repository, currentDocId } = this.props;
    repository && getTocList({ repositoryId: repository.id }).then((result) => {
      this.setState({
        treeData: getTreeFromFlatData({ flatData: result.repositoryTocs, rootKey: null, active: currentDocId }),
        loading: false,
      });
    }).catch((errors) => {
      window.App.alert(errors);
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

  onDeleteNode = (params, reload) => {
    if (!window.confirm(this.t('.Are you sure to delete'))) {
      return false;
    }

    deleteToc(params).then((result) => {
      window.App.notice(this.t('.Toc has successfully deleted'));
      // 当删除项是当前阅读的文档
      if (reload) {
        window.Turbolinks.visit(window.location.href);
      } else {
        this.getTocList();
      }
    });

    return true;
  }

  t = (key) => {
    if (key.startsWith('.')) {
      return window.i18n.t(`toc-tree${key}`);
    }
    return window.i18n.t(key);
  }

  onChange = treeData => this.setState({ treeData })

  toggleEditMode = () => this.setState({ editMode: !this.state.editMode })

  handleCreate = () => {
    const { repository } = this.props;
    const { treeData } = this.state;
    dialog({
      title: this.t('.Create Doc'),
      type: 'createToc',
      info: treeData[0],
      repository,
      position: 'left',
      t: this.t,
      onSuccessBack: (result) => {
        const newTreeData = update(treeData, { $splice: [[0, 0, result]] });
        this.onChange(newTreeData);
      },
    });
  }

  renderItems() {
    const {
      loading, treeData, editMode, viewMode,
    } = this.state;
    const { repository, currentDocId } = this.props;
    if (loading) {
      return <TreeLoader />;
    }

    if (viewMode === 'list') {
      return <ul className="toc-items">
        {treeData.map(toc => <ListNode toc={toc}
          onDeleteNode={this.onDeleteNode}
          t={this.t}
          editMode={editMode}
          repository={repository}
          currentDocId={currentDocId}
        />)}
      </ul>;
    }

    return <Tree
      treeData={treeData}
      editMode={editMode}
      viewMode={viewMode}
      onChange={this.onChange}
      onMoveNode={this.onMoveNode}
      onDeleteNode={this.onDeleteNode}
      repository={repository}
      currentDocId={currentDocId}
      // 默认折叠的层级
      expandedDepth={3}
      t={this.t}
     />;
  }

  render() {
    const { editMode, canEdit } = this.state;
    const { repository, user, type } = this.props;
    return (
      <MuiThemeProvider theme={theme}>
        <div className="toc-tree" data-edit-mode={editMode}>
          {type === 'side' && (
            <div className="toc-tree-toolbar doc-parents">
              <a className="link-back text-main" href={repository.path}>{repository.name}</a>
              <a className="link-group text-gray-light" href={user.path}>{user.name}</a>
            </div>
          )}
          {type === 'center' && canEdit && (
            <div className="repo-toc-toolbar">
              <div className='btn btn-sm btn-success btn-new-doc' onClick={this.handleCreate}>
                <Icon name="add-doc" /> {this.t('.Create Doc')}
              </div>

              <label className={'edit-switch'}>
                <span>{this.t('.Edit Toc')}</span>
                <Switch
                  checked={this.state.editMode}
                  value="editMode"
                  color="primary"
                  onChange={this.toggleEditMode}
                />
              </label>
            </div>
          )}
          {type === 'side' && canEdit && (
            <div
              className="toc-tree-bottom-toolbar btn-new btn-block"
              onClick={this.handleCreate}
            >
              <Icon name="add-doc" /> {this.t('.Create Doc')}
            </div>
          )}
          {this.renderItems()}
        </div>
      </MuiThemeProvider>
    );
  }
}

const TreeLoader = () => (
  <div style={{ width: '230px', height: '220px' }}>
    <ContentLoader
      height={220}
      width={230}
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
);

export default TocTree;
