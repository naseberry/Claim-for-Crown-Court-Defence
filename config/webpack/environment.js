const {
  environment
} = require('@rails/webpacker')
const webpack = require('webpack')

environment.plugins.append('Provide', new webpack.ProvidePlugin({
  accessibleAutocomplete: 'accessible-autocomplete',
  Dropzone: 'Dropzone',
  $: 'jquery',
  jQuery: 'jquery',
  jquery: 'jquery'
}))

const config = environment.toWebpackConfig();
config.resolve.alias = {
  Dropzone: 'dropzone/dist/dropzone',
  jquery: 'jquery/src/jquery'
}

module.exports = environment
