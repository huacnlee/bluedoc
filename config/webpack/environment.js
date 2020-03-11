const { environment } = require('@rails/webpacker');
const erb = require('./loaders/erb');

const nodeModulesLoader = environment.loaders.get('nodeModules');
if (!Array.isArray(nodeModulesLoader.exclude)) {
  nodeModulesLoader.exclude = (nodeModulesLoader.exclude == null)
    ? []
    : [nodeModulesLoader.exclude];
}
nodeModulesLoader.exclude.push(/ckeditor5\/*/);

const extendConfig = {
  externals: {
    react: 'React',
    'react-dom': 'ReactDOM',
    'react-dom/server': 'ReactDOMServer',
    jquery: 'jQuery',
    'rails-ujs': 'Rails',
    turbolinks: 'Turbolinks',
  },
  // optimization: {
  //   splitChunks: {
  //     cacheGroups: {
  //       vendors: {
  //         test: /node_modules|vendor/,
  //         name: 'vendors',
  //         enforce: true,
  //         chunks: 'initial'
  //       }
  //     }
  //   }
  // },
};

environment.config.merge(extendConfig);

environment.loaders.prepend('erb', erb);
module.exports = environment;
