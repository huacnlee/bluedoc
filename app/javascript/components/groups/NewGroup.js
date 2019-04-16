import { Form, FormGroup, ControlLabel } from "bluebox/form";
import { PrimaryButton } from "bluebox/button";

const slugFormat = /[^A-Za-z0-9\-\_\.]/g;

export default class NewGroup extends React.Component {
  constructor(props) {
    super(props)

    const { group } = props;

    this.formRef = React.createRef();

    this.state = {
      slug: group.slug,
      name: group.name,
      hasInputedSlug: false,
      randomSlug: Math.random().toString(36).substring(8),
    }
  }

  t = (key) => {
    if (key.startsWith('.')) {
      return i18n.t(`groups.NewGroup${key}`);
    }
    return i18n.t(key);
  }

  onNameChange = (e) => {
    let name = e.currentTarget.value;

    const { hasInputedSlug, randomSlug } = this.state;

    let autoSlug = name.replace(slugFormat, "-").toLowerCase();
    if (autoSlug.replace(/[-]/g, "").length <= 2) {
      autoSlug = randomSlug;
    }

    if (!hasInputedSlug) {
      this.setState({
        slug: autoSlug,
      })
    }
  }

  onSlugChange = (e) => {
    const value = e.currentTarget.value;

    if (value.length > 0) {
      this.setState({
        hasInputedSlug: true,
      })
    } else {
      this.setState({
        hasInputedSlug: false,
      })
    }
  }

  onSubmit = (e) => {
    const form = this.formRef.current;
    form.submit();
  }

  render() {
    const { slug, name, description } = this.state;
    const { group } = this.props;
    const { t } = this;

    return <div className="new-group-form">
      <div className="heading mb-4">
        <div className="f1 mb-2">{t(".New Group")}</div>
        <div className="text-main">{t(".Group accounts allow your team to plan, build, review, and ship documents")}</div>
      </div>

      <Form action="/groups" method="POST" ref={this.formRef}>
        <FormGroup name="name" object={group}>
          <ControlLabel name={t(".Name")} />
          <input type="text" className="form-control" name="group[name]" style={{ width: "250px" }} onChange={this.onNameChange} defaultValue={name} />
          <div class="form-text">{t(".Display title of this Group")}</div>
        </FormGroup>

        <FormGroup name="slug" object={group}>
          <ControlLabel name={t(".Slug")} />
          <div className="input-group d-flex">
            <div className="input-group-prepend"><div className="input-group-text text-overflow">{App.host}/</div></div>
            <input type="text" className="form-control" onChange={this.hasInputedSlug} name="group[slug]" defaultValue={slug} />
          </div>
          <div class="form-text">
            <p>{t(".Great group path names are short and memorable")}</p>
            <p>{t(".The letters, numbers or dash is allow, for example")} <code>BlueDoc-Help</code></p>
          </div>
        </FormGroup>

        <FormGroup name="description" object={group}>
          <ControlLabel name={t(".Description")} />

          <textarea name="group[description]" defaultValue={description} className="form-control" />
        </FormGroup>

        <div class="actions">
          <PrimaryButton style={{ width: "200px" }} onClick={this.onSubmit} disableWith="Submiting...">{t(".Create Group")}</PrimaryButton>
        </div>
      </Form>
    </div>
  }
}
