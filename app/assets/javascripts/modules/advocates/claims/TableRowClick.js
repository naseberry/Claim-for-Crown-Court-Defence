"use strict";

var moj = moj || {};

moj.Modules.TableRowClick = {
  init: function() {
    $('.js-checkbox-table').on('click', function(e) {
      var $target = $(e.target);
      if($target.is(':checkbox')) {
        return;
      }
      var $tr = $target.closest('tr');
      var $checkbox = $tr.find(':checkbox');
      $checkbox.prop('checked', !$checkbox.is(':checked'));
    });
  }
};
