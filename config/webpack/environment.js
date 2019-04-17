const { environment } = require('@rails/webpacker');
const erb =  require('./loaders/erb');

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

environment.loaders.prepend('erb', erb)
module.exports = environment;
