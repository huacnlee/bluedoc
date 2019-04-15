import { graph } from 'bluedoc/graphql';

// fetch toc list
export const getTocList = graph(`
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

// move toc and sort
export const moveTocList = graph(`
  mutation (@autodeclare) {
    moveToc(id: $id, targetId: $targetId, position: $position )
  }
`);

// delete toc node
export const deleteToc = graph(`
  mutation (@autodeclare) {
    deleteToc(id: $id)
  }
`);

// update toc info {title , url}
export const updateToc = graph(`
  mutation (@autodeclare) {
    updateToc(id: $id, title: $title, url: $url)
  }
`);
