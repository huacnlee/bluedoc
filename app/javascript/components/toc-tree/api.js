import { graph } from 'bluedoc/graphql';

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

export const moveTocList = graph(`
  mutation (@autodeclare) {
    moveToc(id: $id, targetId: $targetId, position: $position )
  }
`);

export const deleteToc = graph(`
  mutation (@autodeclare) {
    deleteToc(id: $id)
  }
`);

export const updateToc = graph(`
  mutation (@autodeclare) {
    updateToc(id: $id, title: $title, url: $url)
  }
`);
