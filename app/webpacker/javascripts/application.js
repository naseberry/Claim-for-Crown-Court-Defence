/*global GOVUK*/
import './polyfill.object.keys';
import 'jquery/src/jquery';
import 'jquery-ujs/src/rails';
import './jquery.iframe-transport';
import './jquery.remotipart';
import 'cocoon/app/assets/javascripts/cocoon';
import 'dropzone';
import './vendor/polyfills/bind';
import 'govuk_frontend_toolkit/javascripts/govuk/stick-at-top-when-scrolling';
import 'govuk_frontend_toolkit/javascripts/govuk/stop-scrolling-at-footer';
import './moj';
import './modules/moj.cookie-message';
import './jquery-accessible-accordion-aria';
import './typeahead-aria';
import './jquery.jq-element-revealer';
// import './jquery.datatables.min';
import 'datatables.net-dt';
import 'datatables.net-buttons-dt';
import 'datatables.net-buttons';
import 'datatables.net-fixedheader-dt';
import './jsrender.min';
import 'jquery-highlight/jquery.highlight';
import './jquery.ba-throttle-debounce';
import 'accessible-autocomplete';
import './modules/Helpers.API.Core';
import './modules/Helpers.API.Distance';
import './modules/Helpers.API.Establishments';
import './modules/Helpers.Autocomplete';
import './modules/Helpers.DataTables';
import './modules/Helpers.FormControls';
import './modules/Modules.AddEditAdvocate';
import './modules/Modules.AllocationDataTable';
import './modules/Modules.AllocationFilterSubmit';
import './modules/Modules.AllocationScheme';
import './modules/Modules.AmountAssessed';
import './modules/Modules.Autocomplete';
import './modules/Modules.DataTables';
import './modules/Modules.ExpensesDataTable';
import './modules/Modules.HideErrorOnChange';
import './modules/Modules.Messaging';
import './modules/Modules.OffenceSearchInput';
import './modules/Modules.OffenceSearchView';
import './modules/Modules.OffenceSelectedView';
import './modules/Modules.Providers';
import './modules/Modules.SelectAll';
import './modules/Modules.TableRowClick';
import './modules/Plugin.jqDataTable.filter';
import './modules/case_worker/Allocation';
import './modules/case_worker/ReAllocation';
import './modules/case_worker/admin/Modules.ManagementInformation';
import './modules/case_worker/claims/DeterminationCalculator';
import './modules/details.polyfill';
import './modules/external_users/claims/BasicFeeDateCtrl';
import './modules/external_users/claims/BlockHelpers';
import './modules/external_users/claims/CaseTypeCtrl';
import './modules/external_users/claims/ClaimIntentions';
import './modules/external_users/claims/CocoonHelper';
import './modules/external_users/claims/DisbursementsCtrl';
import './modules/external_users/claims/Dropzone';
import './modules/external_users/claims/DuplicateExpenseCtrl';
import './modules/external_users/claims/FeeFieldsDisplay';
import './modules/external_users/claims/FeePopulator';
import './modules/external_users/claims/FeeSectionDisplay';
import './modules/external_users/claims/InterimFeeFieldsDisplay';
import './modules/external_users/claims/NewClaim';
import './modules/external_users/claims/OffenceCtrl';
import './modules/external_users/claims/SchemeFilter';
import './modules/external_users/claims/SideBar';
import './modules/external_users/claims/TransferDetailFieldsDisplay';
import './modules/external_users/claims/TransferDetailsCtrl';
import './modules/external_users/claims/fee_calculator/FeeCalculator.GraduatedPrice';
import './modules/external_users/claims/fee_calculator/FeeCalculator.UnitPrice';
import './modules/external_users/claims/fee_calculator/FeeCalculator';
import './modules/show-hide-content';
import './plugins/jquery.numbered.elements';


// TINY PUBSUB
// Great little wrapper to easily do pub/sub

/* jQuery Tiny Pub/Sub - v0.7 - 10/27/2011
 * http://benalman.com/
 * Copyright (c) 2011 "Cowboy" Ben Alman; Licensed MIT, GPL */

(function ($) {

  var o = $({});

  $.subscribe = function () {
    o.on.apply(o, arguments);
  };

  $.unsubscribe = function () {
    o.off.apply(o, arguments);
  };

  $.publish = function () {
    o.trigger.apply(o, arguments);
  };

}(jQuery));


// Trunc polyfil
String.prototype.trunc = String.prototype.trunc || function (n) {
  return (this.length > n) ? this.substr(0, n - 1) + '&hellip;' : this;
};

// Simple string interpolation
if (!String.prototype.supplant) {
  String.prototype.supplant = function (o) {
    return this.replace(
      /\{([^{}]*)\}/g,
      function (a, b) {
        var r = o[b];
        return typeof r === 'string' || typeof r === 'number' ? r : a;
      }
    );
  };
}

(function () {
  'use strict';
  delete moj.Modules.devs;

  jQuery.fn.exists = function () {
    return this.length > 0;
  };


  // Where .multiple-choice uses the data-target attribute
  // to toggle hidden content
  var showHideContent = new GOVUK.ShowHideContent();
  showHideContent.init();


  // Sticky sidebar
  // TODO: Re-init / reset the screen dimentions as page expands
  GOVUK.stickAtTopWhenScrolling.init();

  /**
   * Cocoon call back to init features once they have been
   * interted into the DOM
   */
  $('#fixed-fees, #misc-fees, #documents').on('cocoon:after-insert', function (e, insertedItem) {
    var $insertedItem = $(insertedItem);
    var insertedSelect = $insertedItem.find('select.typeahead');
    var typeaheadWrapper = $insertedItem.find('.js-typeahead');

    moj.Modules.Autocomplete.typeaheadKickoff(insertedSelect);
    moj.Modules.Autocomplete.typeaheadBindEvents(typeaheadWrapper);
    moj.Modules.FeeFieldsDisplay.addFeeChangeEvent(insertedItem);

    $insertedItem.find('.remove_fields:first').focus();
  });

  // Basic fees page
  $('#basic-fees').on('change', '.js-block input', function () {
    $(this).trigger('recalculate');
  });

  $('#basic-fees').on('change', '.js-fee-rate, .js-fee-quantity', function () {
    var $el, quantity, rate, amount;

    $el = $(this).closest('.basic-fee-group');
    quantity = $el.find('.js-fee-quantity').val();
    rate = $el.find('.js-fee-rate').val();
    amount = quantity * rate;

    $el.find('.js-fee-amount').val(amount.toFixed(2));
  });

  // this is a bit hacky
  // TODO: To be moved to more page based controllers
  $('#basic-fees').on('change', '.multiple-choice input[type=checkbox]', function (e) {
    var checked = $(e.target).is(':checked');
    var fields_wrapper = $(e.target).attr('aria-controls');
    var $fields_wrapper = $('#' + fields_wrapper);

    $fields_wrapper.find('input[type=number]').val(0);
    $fields_wrapper.find('input[type=text]').val('');
    $fields_wrapper.find('.gov_uk_date input[type=number]').val('');
    $fields_wrapper.find('.gov_uk_date input[type=number]').prop('disabled', !checked);
    $fields_wrapper.trigger('recalculate');
  });

  /**
   * Fee calculation event binding for added fees
   */
  $('#misc-fees').on('cocoon:after-insert', function (e, insertedItem) {
    var $insertedItem = $(insertedItem);
    moj.Modules.FeeCalculator.UnitPrice.miscFeeTypesSelectChange($insertedItem.find('.fx-misc-fee-calculation'));
    moj.Modules.FeeCalculator.UnitPrice.feeQuantityChange($insertedItem.find('.js-fee-calculator-quantity'));
    moj.Modules.FeeCalculator.UnitPrice.feeRateChange($insertedItem.find('.js-fee-calculator-rate'));
  });

  // Manually hit the `add rep order` button after a
  // cocoon insert.
  $('.form-actions').on('cocoon:after-insert', function (e, el) {
    var $el = $(el);
    if ($el.hasClass('resource-details')) {
      $el.find('a.add_fields').click();
    }
  });

  //Stops the form from submitting when the user presses 'Enter' key
  $('#claim-form, #claim-status').on('keypress', function (e) {
    if (e.keyCode === 13 && (e.target.type !== 'textarea' && e.target.type !== 'submit')) {
      return false;
    }
  });



  moj.Helpers.token = (function (name) {
    return $('form input[name=' + name + '_token]').val();
  }(['au', 'th', 'ent', 'ici', 'ty'].join(''))); //;-)

  moj.init();
  $.numberedList();
}());
