moj.Modules.FeeCalculator = {
  init: function () {
    this.bindEvents();
  },

  bindEvents: function () {
    this.advocateTypeChange();
    this.fixedFeeTypeChange();
    this.fixedFeeRateChange();
    this.fixedFeeQuantityChange();
  },

  advocateTypeChange: function () {
    var self = this;
    if ($('.calculated-fixed-fee').exists()) {
      $('.js-fixed-fee-calculator-advocate-type').change( function() {
        self.calculateUnitPriceFixedFee();
      });
    }
  },

  // needs to be usable by cocoon:after-insert so can bind to one or many elements
  fixedFeeTypeChange: function ($el) {
    var self = this;
    var $els = $el || $('.js-fixed-fee-calculator-fee-type');
    if ($('.calculated-fixed-fee').exists()) {
      $els.change( function() {
        self.calculateUnitPriceFixedFee();
      });
    }
  },

  // needs to be usable by cocoon:after-insert so can bind to one or many elements
  fixedFeeQuantityChange: function ($el) {
    var self = this;
    var $els = $el || $('.js-fixed-fee-calculator-quantity');
    if ($('.calculated-fixed-fee').exists()) {
      $els.change( function() {
        self.calculateUnitPriceFixedFee();
        self.populateNetAmount(this);
      });
    }
  },

  // needs to be usable by cocoon:after-insert so can bind to one or many elements
  fixedFeeRateChange: function ($el) {
    var self = this;
    var $els = $el || $('.js-fixed-fee-calculator-rate');
    $els.change( function() {
      self.populateNetAmount(this);
    });
  },

  setRate: function(data, context) {
    var $input = $(context).find('input.fee-rate');
    var $calculated = $(context).closest('.fixed-fee-group').find('.js-fixed-fee-calculator-success').find('input');
    $input.val(data.toFixed(2));
    $input.change();
    $calculated.val(data > 0);
    $input.prop('readonly', data > 0);
  },

  enableRate: function(context) {
    $(context).find('input.fee-rate').prop('readonly', false);
  },

  populateNetAmount: function(context) {
    var $el = $(context).closest('.fixed-fee-group').find('.fee-net-amount');
    var rate = $(context).closest('.fixed-fee-group').find('input.fee-rate').val();
    var quantity = $(context).closest('.fixed-fee-group').find('input.fee-quantity').val();
    var value = (rate * quantity);
    var text = '&pound;' + moj.Helpers.SideBar.addCommas(value.toFixed(2));
    $el.html(text);
  },

  displayError: function(response, context) {
    // only some errors will have a JSON response
    //TODO:remove the console.log debug
    try { console.log(response.responseJSON.errors); } catch(e) {}
    this.clearErrors(context);
    var $label = $(context).find('label');
    var $calculated = $(context).closest('.fixed-fee-group').find('.js-fixed-fee-calculator-success').find('input');
    var error_html = '<div class="js-calculate-error form-hint">' + response.responseJSON["message"] + '<div>';
    var new_label = $label.text() + ' ' + error_html;
    var $input = $(context).find('input.fee-rate');

    $input.val('');
    $input.prop("readonly", false);
    $calculated.val(false);
    $label.html(new_label);
  },

  clearErrors: function(context) {
    $(context).find('.js-calculate-error').remove();
  },

  displayHelp: function(context, show) {
    var $help = $(context).closest('.fixed-fee-group').find('.help-wrapper.form-group');
    show ? $help.show() : $help.hide();
  },

  unitPriceAjax: function (data, context) {
    var self = this;
    $.ajax({
      type: 'GET',
      url: '/external_users/claims/' + data.claim_id + '/calculate_unit_price.json',
      data: data,
      dataType: 'json'
    })
    .done(function(response) {
      self.clearErrors(context);
      self.setRate(response.data.amount, context);
      self.displayHelp(context, true);
    })
    .fail(function(response) {
      if (response.responseJSON['errors'][0] != 'incomplete') {
        self.displayError(response, context);
        self.displayHelp(context, false);
      }
      self.enableRate(context);
    });
  },

  addFixedFeeData: function(data) {
    data.claim_id = $('#claim-form').data('claimId');
    data.advocate_category = $('input:radio[name="claim[advocate_category]"]:checked').val();

    var fees = data.fees = [];
    $('.fixed-fee-group:visible').each(function() {
      fees.push({
        fee_type_id: $(this).find('select.js-fee-type').val(),
        quantity: $(this).find('input.js-fee-quantity').val()
      });
    });
  },

  // Calculates the "unit price" for a given fixed fee,
  // including fixed fee case uplift fee types.
  calculateUnitPriceFixedFee: function () {
    var self = this;
    var data = {};
    self.addFixedFeeData(data);

    $('.js-fixed-fee-calculator-effectee').each(function() {
      data.fee_type_id = $(this).closest('.fixed-fee-group').find('select.js-fee-type').val();
      self.unitPriceAjax(data, this);
    });
  }
};