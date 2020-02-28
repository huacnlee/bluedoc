import { Icon } from 'bluebox/iconfont';

export const TitleInput = ({ t, onChange, value }) => (
  <div className="form-group">
    <label className="control-label">{t('.Title')}</label>
    <input className="form-control" type="text" autoFocus onChange={onChange} value={value} />
  </div>
);

export const FormatSelect = ({ t, onChange, value }) => (
  <div className="form-group">
    <label className="control-label">{t('.Format')}</label>
    <select onChange={onChange} value={value} className="form-control">
      <option value="sml">{t('.RichText')}</option>
      <option value="markdown">{t('.Markdown')}</option>
    </select>
  </div>
);

export const MarkdownInput = ({ t, onChange, value }) => (
  <div className="form-group">
    <label className="form-input-file">
      <div className="btn btn-upload mb-2">
        <div>
          <Icon name="file" /> {t('.Select markdown file')}
        </div>
        <div className="text-gray mt-1">{value}</div>
      </div>
      <input type="file" className="form-control" accept=".md" onChange={onChange} />
    </label>
    <div className="form-text">{t('.Import markdown tips')}</div>
  </div>
);

export const UrlInput = ({
  t, onChange, value, prefix,
}) => (
    <div className="form-group mb-button">
      <label className="control-label">{t('.Url')}</label>
      <div className="input-group d-flex">
        <div className="input-group-prepend">
          <div className="input-group-text">{`${prefix}/`}</div>
        </div>
        <input
          className="form-control"
          type="text"
          value={value}
          placeholder={'slug'}
          onChange={onChange}
        />
      </div>
    </div>
  );

export const ExternalInput = ({ t, onChange, value }) => (
  <div className="form-group mb-button">
    <label className="control-label">{t('.External Url')}</label>
    <input
      className="form-control"
      type="text"
      value={value}
      placeholder={'https://bluedoc.io/'}
      onChange={onChange}
    />
  </div>
);
