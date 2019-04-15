import { graph } from 'bluedoc/graphql';

const getDocs = graph(`
  query (@autodeclare) {
    repositoryDocs(repositoryId: $repositoryId, sort: $sort, per: 10, page: $page) {
      records {
        id, title, slug, path, createdAt, updatedAt,
        lastEditor {
          id, name, slug, avatarUrl, path
        },
      },
      pageInfo { per, page, totalCount, totalPages, firstPage, lastPage, nextPage, prevPage }
    }
  }
`);
