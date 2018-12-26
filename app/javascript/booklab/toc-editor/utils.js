
// find visible cur node's sort index
export const getCurNode = (curIndex, items) => {
  if (curIndex === -1) return -1;
  return items.find(v => v.index === curIndex);
};

// find visible prev node's sort index
export const getPrevNodeIndex = (curIndex, items) => {
  if (curIndex === -1) return -1;
  const tempIdx = items.findIndex(v => v.index === curIndex) - 1;
  const { index = -1 } = items[tempIdx] || {};
  return index;
};
// find visible next node's sort index
export const getNextNodeIndex = (curIndex, items) => {
  if (curIndex === -1) return -1;
  const tempIdx = items.findIndex(v => v.index === curIndex) + 1;
  const { index = -1 } = items[tempIdx] || {};
  return index;
};

// get folderList length
export const getFolderLength = (curIndex, items) => {
  const curEle = items[curIndex];
  const otherArr = items.slice(curIndex + 1);
  const idx = otherArr.findIndex(v => v.depth <= curEle.depth);
  return idx === -1 ? otherArr.length : idx;
};
