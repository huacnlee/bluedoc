import BaseTooltip from '@material-ui/core/Tooltip';
import { Theme } from "bluebox/theme";

export class Tooltip extends React.Component {
  render() {
    return <Theme>
      <BaseTooltip {...this.props}>{this.props.children}</BaseTooltip>
    </Theme>
  }
}
