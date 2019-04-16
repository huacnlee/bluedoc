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
  mutation (
    $id: ID!,
    $title: String!,
    $url: String,
  ) {
    updateToc(id: $id, title: $title, url: $url)
  }
`);

// create toc
export const createToc = graph(`
  mutation (
    $repositoryId: ID!,
    $title: String!,
    $url: String,
    $external: Boolean,
    $targetId: ID,
    $position: String
  ) {
    createToc(
      repositoryId: $repositoryId,
      title: $title,
      url: $url,
      external: $external,
      targetId: $targetId,
      position: $position
    ) {
      id,
      title,
      url,
    }
  }
`);
