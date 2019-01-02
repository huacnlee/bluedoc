import "booklab"

require.context('../images/', true, /\.(gif|jpg|png|svg)$/i)

// react-rails init
var componentRequireContext = require.context("components", true)
var ReactRailsUJS = require("react_ujs")
ReactRailsUJS.useContext(componentRequireContext)