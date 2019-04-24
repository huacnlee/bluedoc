import BaseSwitch from '@material-ui/core/Switch';
import { Theme } from "bluebox/theme";

export class Switch extends React.Component {
  render() {
    return (<Theme>
      <BaseSwitch {...this.props} />
    </Theme>)
  }
}
