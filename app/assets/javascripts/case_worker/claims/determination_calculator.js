"use strict";

var adp = adp || {};

adp.determination = {
  init : function(container_id) {
    this.addChangeEvent(container_id);
  },
  calculateAmount: function(fee, expenses) {

    var f = fee || 0,
      e = expenses || 0;
    f = f < 0 ? 0 : f;
    e = e < 0 ? 0 : e;
    var t = (f + e).toFixed(2);
    t = t < 0 ? 0 : t;
    console.log(t);
    return t;

  },
  addChangeEvent: function(container_id) {
    $('#' + container_id).on('change', '#claim_assessment_attributes_fees, #claim_assessment_attributes_expenses', function(e) {
      var wrapper  = $(e.target).closest('.nested-fields');
      var fees = parseFloat($('#claim_assessment_attributes_fees').val());
      var expenses     = parseFloat($('#claim_assessment_attributes_expenses').val());
      var total = adp.determination.calculateAmount(fees,expenses);
      if (isNaN(total) ){
        $('.total-determination').text('£0.00');
      }
      else{
        $('.total-determination').text('£ '+ total);
      }
    });
  }
};
