import { Icon } from 'bluebox/iconfont';
import { UserAvatar } from 'bluebox/avatar';
import { Form, FormGroup, ControlLabel } from 'bluebox/form';
import { PrimaryButton } from 'bluebox/button';
import { Tab } from 'bluebox/tab';

const { Component } = React;

const slugFormat = /[^A-Za-z0-9\-\_\.]/g;

class GroupSelectMenu extends Component {
  constructor(props) {
    super(props);

    this.container = React.createRef();

    this.state = {
      currentName: this.t('.Choose an item'),
      value: props.value,
      active: false,
    };
  }

  t = (key) => {
    if (key.startsWith('.')) {
      return i18n.t(`repositories.new${key}`);
    }
    return i18n.t(key);
  }

  componentDidMount = () => {
    const { value, items } = this.props;

    const currentItem = items.find(item => item.id == value);
    if (currentItem) {
      this.setState({
        currentName: currentItem.name,
      });
    }
  }

  dismiss = () => {
    this.container.current.removeAttribute('open');
  }

  onSelectItem = (newValue, newName) => {
    this.setState({
      value: newValue,
      currentName: newName,
    });
    this.dismiss();
  }

  renderItem(props) {
    const { item, name } = props;
    const { value } = this.state;
    const selected = value == item.id;

    let className = 'select-menu-item js-navigation-item';
    if (selected) {
      className += ' selected';
    }

    return <label class={className} onClick={ e => this.onSelectItem(item.id, item.name) }>
      <input type="radio" name={name} value={item.id} checked={selected} />
      <Icon name="check" className="icon-check select-menu-item-icon"></Icon>
      <div className="select-menu-item-text">
        <UserAvatar user={item} type="tiny" link={false} />
        {item.name}
      </div>
    </label>;
  }

  renderItems() {
    const { items, value, name } = this.props;

    return items.map(item => this.renderItem({ name, item, value }));
  }

  render() {
    const { currentName } = this.state;

    return <details style={{ minWidth: '120px', maxWidth: '210px' }} className="dropdown position-relative details-overlay details-reset" ref={this.container}>
      <summary className="btn select-menu-button">
        <span>{currentName}</span>
      </summary>
      <div className="dropdown-menu dropdown-menu-se" style={{ minWidth: '210px' }}>
        <div className="select-menu-list">
          {this.renderItems()}
        </div>
      </div>
    </details>;
  }
}

export default class NewRepository extends Component {
  constructor(props) {
    super(props);

    const { repository } = props;

    this.formRef = React.createRef();

    this.state = {
      repository,
      slug: repository.slug,
      name: repository.name,
      privacy: repository.privacy,
      hasInputedSlug: false,
      provider: props.provider,
      randomSlug: Math.random().toString(36).substring(8),
      selectedFileName: this.t('.Select File'),
    };
  }

  t = (key) => {
    if (key.startsWith('.')) {
      return i18n.t(`repositories.new${key}`);
    }
    return i18n.t(key);
  }

  onSelectFile = (e) => {
    const { value } = e.target;
    const selectedFileName = value.split('\\').pop();
    this.setState({ selectedFileName });
  }

  onImportTabChanged = (index) => {
    if (index == 0) {
      this.setState({ provider: 'archive' });
    } else {
      this.setState({ provider: 'gitbook' });
    }
  }

  onSourceURLChanged = (e) => {
    const { value } = e.target;

    const { repository } = this.props;

    if (value.length > 0 && !value.match(/http[s]:\/\//gi)) {
      repository.errors.gitbook_url = this.t('.Invalid git source url format');
      this.setState({ repository });
    } else {
      repository.errors.gitbook_url = null;
      this.setState({ repository });
    }
  }

  renderImportInputs() {
    const { type } = this.props;
    const { repository, selectedFileName, provider } = this.state;
    const { t } = this;
    if (type !== 'import') {
      return <div />;
    }

    const tabs = [t('.Import from Archive'), t('.Import from Git')];

    return <div className="import-box card-static mb-4">
      <Tab items={tabs} onSelect={this.onImportTabChanged} />
      {provider == 'gitbook' && (
        <FormGroup name="gitbook_url" object={repository}>
          <input type="text" name="repository[gitbook_url]" autoComplete={false} onChange={this.onSourceURLChanged} className="form-control" placeholder="https://github.com/somewhere/gitbook.git" />
          <div className="form-text">
            <div dangerouslySetInnerHTML={{ __html: t('.Enter a Git repository URL_html') }}></div>
            <div dangerouslySetInnerHTML={{ __html: t('.This feature is best compatible with_html') }}></div>
          </div>
        </FormGroup>
      )}
      {provider != 'gitbook' && (
        <FormGroup name="import_archive" object={repository}>
          <label className="form-input-file">
            <span className="btn mb-2"><Icon name="text-attachment" /> {selectedFileName}</span>
            <input type="file" name="repository[import_archive]" className="form-control" accept="application/zip" onChange={this.onSelectFile} />
          </label>
          <div className="form-text">
            <div dangerouslySetInnerHTML={{ __html: t('.You can archive multiple markdown files as a zip file, and then choice the zip file for import_html') }}></div>
          </div>
        </FormGroup>
      )}
    </div>;
  }

  onNameChange = (e) => {
    const name = e.currentTarget.value;

    const { hasInputedSlug, randomSlug } = this.state;

    let autoSlug = name.replace(slugFormat, '-').toLowerCase();
    if (autoSlug.replace(/[-]/g, '').length <= 2) {
      autoSlug = randomSlug;
    }

    if (!hasInputedSlug) {
      this.setState({
        slug: autoSlug,
      });
    }
  }

  onSlugChange = (e) => {
    const { value } = e.currentTarget;

    if (value.length > 0) {
      this.setState({
        hasInputedSlug: true,
      });
    } else {
      this.setState({
        hasInputedSlug: false,
      });
    }
  }

  onPrivacyChange = (e) => {
    this.setState({
      privacy: e.target.value,
    });
  }

  onSubmit = (e) => {
    const form = this.formRef.current;
    form.submit();
  }

  render() {
    const { type, groups } = this.props;
    const { t } = this;

    const {
      repository, slug, name, privacy,
    } = this.state;

    return <div className="new-repository-form" type={type}>
      <div className="sub-title mb-4">
        <div className="heading mb-3">
          {type == 'import' && (t('.Import Repository'))}
          {type != 'import' && (t('.New Repository'))}
        </div>
        <div className="text-main">{t('.A repository contains all the documents for your project')}</div>
      </div>

      <Form action={this.props.action} method="post" enctype="multipart/form-data" ref={this.formRef}>
        <input type="hidden" name="_by" value={type} />

        {this.renderImportInputs()}

        <FormGroup name="name" object={repository}>
          <ControlLabel name={t('activerecord.attributes.repository.name')}></ControlLabel>
          <input type="text" className="form-control" name="repository[name]" style={{ maxWidth: '400px' }} onChange={this.onNameChange} defaultValue={name} />
        </FormGroup>

        <div className="form-group">
          <div className="d-flex">
            <FormGroup name="user_id" object={repository} className="mr-2 mb-0">
              <ControlLabel name={t('activerecord.attributes.repository.user')}></ControlLabel>
              <GroupSelectMenu items={groups} name="repository[user_id]" value={repository.user_id} />
            </FormGroup>

            <FormGroup name="user_id" object={repository} className="flex-auto mb-0">
              <ControlLabel name={t('activerecord.attributes.repository.slug')}></ControlLabel>
              <input type="text" className="form-control" onChange={this.onSlugChange} style={{ maxWidth: '320px' }} name="repository[slug]" defaultValue={slug} />
            </FormGroup>
          </div>
          <div class="form-text">{t('.Great repository names are short and memorable')}</div>
        </div>

        <FormGroup name="privacy" object={repository}>
          <ControlLabel name={t('activerecord.attributes.repository.privacy')}></ControlLabel>

          <div className="form-checkbox">
            <label style={{ display: 'block' }}>
              <input type="radio" name="repository[privacy]" onChange={this.onPrivacyChange} checked={privacy == 'public'} value="public" />
              <span>{t('.Public')}</span>
              <div class="form-text">{t('.Anyone can see this repository')}</div>
            </label>
          </div>
          <div className="form-checkbox">
            <label style={{ display: 'block' }}>
              <input type="radio" name="repository[privacy]" onChange={this.onPrivacyChange} checked={privacy == 'private'} value="private" />
              <span>{t('.Private')}</span>
              <div class="form-text">{t('.You choose who can see and edit to this repository')}</div>
            </label>
          </div>
        </FormGroup>

        <FormGroup name="description" object={repository}>
          <ControlLabel name={t('activerecord.attributes.repository.description')}></ControlLabel>
          <textarea type="text" className="form-control" name="repository[description]" defaultValue={repository.description} />
        </FormGroup>

        <div className="actions">
          <PrimaryButton disableWith="Submiting..." onClick={this.onSubmit}>{t('.Create Repository')}</PrimaryButton>
        </div>
      </Form>
    </div>;
  }
}
