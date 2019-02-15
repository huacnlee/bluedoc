import 'bluedoc';

require.context('../images/', true, /\.(gif|jpg|png|svg)$/i);

// react-rails init
const componentRequireContext = require.context('components', true);
const ReactRailsUJS = require('react_ujs');

ReactRailsUJS.useContext(componentRequireContext);
