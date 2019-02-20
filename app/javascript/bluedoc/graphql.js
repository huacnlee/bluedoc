import graphql from 'graphql.js'

export const graph = graphql("/graphql", {
  method: "POST",
  alwaysAutodeclare: true,
})

export const searchUsers = graph(`
  query(@autodeclare) {
    search(type: "user", query: $query) {
      total,
      records {
        ... on User {
          id, name, slug, avatarUrl
        }
      }
    }
  }
`);
