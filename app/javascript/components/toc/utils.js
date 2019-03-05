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
export const formatItems = (items, currentSlug, defaultFoldeDepth = 1) => {
  const data = JSON.parse(items);
  const prevNodeId = [0];
  const folderNode = [];
  let pathNode = [];
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
  if (currentSlug) {
    const { tocPath } = result.find(v => v.url === currentSlug);
    pathNode = tocPath.split('_');
  }
  const folders = folderNode.map((i) => {
    const foldersStatus = pathNode.indexOf(`${i}`) === -1
      ? result[i].depth > defaultFoldeDepth - 1 : false;
    return {
      id: i,
      foldersStatus,
    };
  });
  return {
    items: result,
    folders,
  };
};
