import FormControlLabel from '@material-ui/core/FormControlLabel';
import { Theme } from 'bluebox/theme';

export default class Switch extends React.Component {
  render() {
    return (
      <Theme>
        <FormControlLabel {...this.props} />
      </Theme>
    );
  }
}
