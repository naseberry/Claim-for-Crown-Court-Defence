/*
 * Libraries required by all environments (i.e jQuery)
 * should be loaded in the config
 * see: ./app/config/webpack/environment.js
 */


// JavaScript
import '../javascripts/application.js';

// Images
require.context('../images', true);
require.context('govuk_frontend_toolkit/images', true);

// Stylesheets
import '../stylesheets/application.scss';
