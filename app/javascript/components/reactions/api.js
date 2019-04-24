import { graph } from 'bluedoc/graphql';

export const updateReaction = graph(`
  mutation(@autodeclare) {
    updateReaction(subjectType: $subjectType, subjectId: $subjectId, name: $name, option: $option) {
      name, url, groupUserSlugs, groupCount
    }
  }
`);
