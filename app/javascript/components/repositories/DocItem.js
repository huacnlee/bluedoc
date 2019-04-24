import { Icon } from 'bluebox/iconfont';;
import { Timeago } from 'bluebox/timeago';
import { UserLink } from 'bluebox/user';
import ContentLoader from 'react-content-loader';

import { graph } from 'bluedoc/graphql';

const deleteDoc = graph(`
  mutation(@autodeclare) {
    deleteDoc(id: $id)
  }
`);

/**
 * Document manage list Item
 */
export class DocItem extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      deleted: false,
      doc: this.props.doc,
    };
  }

  onDelete = (e) => {
    e.preventDefault();

    const { t, onDelete } = this.props;

    const { doc } = this.state;

    if (!confirm(t('.Are you sure to delete this Doc'))) {
      return false;
    }

    deleteDoc({ id: doc.id }).then((result) => {
      onDelete(doc.id);
      App.notice(t('.Doc was successfully destroyed'));
    }).catch((errors) => {
      App.alert(errors);
    });

    return false;
  }

  onEdit = (e) => {
    e.preventDefault();

    const { doc } = this.state;

    Turbolinks.visit(`${doc.path}/edit`);

    return false;
  }

  render() {
    const { repository, user, abilities } = this.props;
    const { doc, deleted } = this.state;

    if (deleted) {
      return <div />;
    }

    return <div className="doc-item list-item list-avatar">
      <div className="avatar-box icon-box icon-doc"><Icon name="avatar-doc" /></div>
      <div className="title text-overflow icon-middle-wrap d-flex">
        <a href={doc.path} className="doc-link" title={doc.title}>{doc.title}</a>
      </div>
      <span className="time-box">
        <Timeago value={doc.updatedAt} />
      </span>
      <div className="path">
        <UserLink user={doc.lastEditor} />
      </div>
      <div className="action action-icon text-gray">
        {abilities.update && (
          <a href="#" onClick={this.onEdit}><Icon name="edit" /></a>
        )}
        {abilities.update && (
          <a href="#" onClick={this.onDelete}><Icon name="trash" /></a>
        )}
      </div>
    </div>;
  }
}

// http://danilowoz.com/create-content-loader/
export const DocItemLoader = () => (
  <div style={{ width: '400px' }}>
    <ContentLoader
      height={60}
      width={400}
      speed={1}
      primaryColor="#f3f3f3"
      secondaryColor="#ecebeb"
    >
      <rect x="53" y="15" rx="4" ry="4" width="205" height="11" />
      <rect x="55" y="39" rx="3" ry="3" width="68" height="6" />
      <circle cx="20" cy="31" r="19" />
    </ContentLoader>
  </div>
);
