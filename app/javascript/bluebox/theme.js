import { MuiThemeProvider, createMuiTheme } from '@material-ui/core/styles';
import { Button } from '@material-ui/core';

const theme = createMuiTheme({
  palette: {
    primary: {
      main: '#2F70FF',
    },
  },
  typography: {
    useNextVariants: true,
    fontFamily: [
      "-apple-system",
      'BlinkMacSystemFont',
      "Helvetica Neue",
      "Helvetica",
      "Arial",
      "sans-serif",
    ],
  },
  overrides: {
    MuiTooltip: {
      tooltip: {
        fontSize: "13px",
        backgroundColor: "#232323",
        borderRadius: "3px",
        maxWidth: "200px",
        lineHeight: "120%",
      }
    }
  }
});

export class Theme extends React.Component {
  render() {
    return <MuiThemeProvider theme={theme}>
      {this.props.children}
    </MuiThemeProvider>
  }
}
