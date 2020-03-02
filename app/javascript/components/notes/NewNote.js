import { Form, FormGroup, ControlLabel } from 'bluebox/form';
import { PrimaryButton } from 'bluebox/button';

export default class NewNote extends React.Component {
  constructor(props) {
    super(props);

    const { note } = props;

    this.formRef = React.createRef();

    this.state = {
      slug: note.slug,
      title: note.title,
      description: note.description,
      hasInputedSlug: false,
      randomSlug: Math.random().toString(36).substring(8),
    };
  }

  t = (key) => {
    if (key.startsWith('.')) {
      return i18n.t(`notes.new${key}`);
    }
    return i18n.t(key);
  }

  onSlugChange = (e) => {
    const { value } = e.currentTarget;

    if (value.length > 0) {
      this.setState({ hasInputedSlug: true });
    } else {
      this.setState({ hasInputedSlug: false });
    }
  }

  onTitleChange = (e) => {
    const title = e.currentTarget.value;

    const { hasInputedSlug, randomSlug } = this.state;

    const autoSlug = App.generateSlugByTitle(randomSlug, title);

    if (!hasInputedSlug) {
      this.setState({
        slug: autoSlug,
      });
    }
  }

  onSubmit = (e) => {
    this.formRef.current.submit();
  }

  onPrivacyChange = (e) => {
    this.setState({
      privacy: e.target.value,
    });
  }

  render() {
    const { action, user, note } = this.props;
    const { t } = this;

    const {
      title, slug, description, privacy,
    } = this.state;

    return <div className="new-note-form">
      <h2 class="sub-title">{t('.New Note')}</h2>
      <Form action={action} method="POST" ref={this.formRef}>
        <FormGroup name="title" object={note}>
          <ControlLabel title={t('activerecord.attributes.note.title')} />
          <input type="text" name="note[title]" style={{ maxWidth: '450px' }} className="form-control" onChange={this.onTitleChange} defaultValue={title} />
        </FormGroup>

        <FormGroup name="slug" object={note}>
          <ControlLabel title={t('activerecord.attributes.note.slug')} />
          <div className="input-group d-flex">
            <div className="input-group-prepend"><div className="input-group-text text-overflow">{user.to_url}/notes/</div></div>
            <input type="text" name="note[slug]" style={{ minWidth: '100px', maxWidth: '250px' }} className="form-control" defaultValue={slug} onChange={this.onSlugChange} />
          </div>
        </FormGroup>

        <FormGroup name="description" object={note}>
          <ControlLabel title={t('activerecord.attributes.note.description')} />
          <textarea name="note[description]" rows="3" className="form-control" defaultValue={description} />
          <div class="form-text">
            {t('.Use a short description to describe of this Note')}
          </div>
        </FormGroup>

        <FormGroup name="format" object={note}>
          <ControlLabel title={t('activerecord.attributes.note.format')} />
          <select name="note[format]" className="form-control">
            <option value="sml">{t('shared.format.sml')}</option>
            <option value="markdown">{t('shared.format.markdown')}</option>
          </select>
        </FormGroup>

        <FormGroup name="privacy" object={note}>
          <ControlLabel title={t('activerecord.attributes.note.privacy')} />
          <div class="form-checkbox">
            <label style={{ display: 'block' }}>
              <input type="radio" name="note[privacy]" onChange={this.onPrivacyChange} checked={privacy != 'private'} value="public" /> {t('.Public')}
              <div class="form-text">{t('.Anyone can see this Note')}</div>
            </label>
          </div>
          <div class="form-checkbox">
            <label style={{ display: 'block' }}>
              <input type="radio" name="note[privacy]" onChange={this.onPrivacyChange} checked={privacy == 'private'} value="private" /> {t('.Private')}
              <div class="form-text">{t('.Only you can see this Note')}</div>
            </label>
          </div>
        </FormGroup>

        <div className="form-actions">
          <PrimaryButton onClick={this.onSubmit} disableWith="Submiting...">{t('.Create Note')}</PrimaryButton>
        </div>
      </Form>
    </div>;
  }
}
