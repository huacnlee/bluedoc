export const isShow = (path, folders) => {
  const pathNode = path.split('_');
  if (pathNode.length > 1) {
    pathNode.pop();
    return !pathNode.some((item) => {
      const folderNode = folders.find(e => e.id * 1 === item * 1);
      return folderNode ? folderNode.foldersStatus : false;
    });
  }
  return true;
};

// format toc items
export const formatItems = (items, defaultFoldeDepth = 1) => {
  const data = JSON.parse(items);
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
    items: result,
    folders: folderNode.map(i => ({
      id: i,
      foldersStatus: result[i].depth > defaultFoldeDepth - 1,
    })),
  };
};
