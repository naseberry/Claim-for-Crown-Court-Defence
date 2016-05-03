And(/^There are supplier numbers in place$/) do
  %w(1A222Z 2B333Z).each do |number|
    @litigator.provider.supplier_numbers << SupplierNumber.new(supplier_number: number)
  end
end

And(/^There are disbursement types in place$/) do
  load "#{Rails.root}/db/seeds/disbursement_types.rb"
end

Then(/^I should be on the litigator new claim page$/) do
  expect(@litigator_claim_form_page).to be_displayed
end

When(/^I select the supplier number '(.*)'$/) do |number|
  @litigator_claim_form_page.select_supplier_number(number)
end

And(/^I select the offence class '(.*)'$/) do |name|
  @litigator_claim_form_page.select_offence_class(name)
end

And(/^I fill '(.*)' as the fixed fee total$/) do |total|
  @litigator_claim_form_page.fixed_fee_total.set total
end

And(/^I enter the case concluded date$/) do
  @litigator_claim_form_page.case_concluded_date.set_date "2016-01-01"
end

And(/^I add a miscellaneous fee '(.*)'$/) do |name|
  @litigator_claim_form_page.add_misc_fee_if_required
  @litigator_claim_form_page.miscellaneous_fees.last.select_fee_type name
  @litigator_claim_form_page.miscellaneous_fees.last.rate.set "135.78"
end

And(/^I add a Case uplift fee with case numbers '(.*)'$/) do |case_numbers|
  step "I add a miscellaneous fee 'Case uplift'"
  @litigator_claim_form_page.miscellaneous_fees.last.case_numbers.set case_numbers
end

And(/^I add a disbursement '(.*)' with net amount '(.*)' and vat amount '(.*)'$/) do |name, net_amount, vat_amount|
  @litigator_claim_form_page.add_disbursement_if_required
  @litigator_claim_form_page.disbursements.last.select_fee_type name
  @litigator_claim_form_page.disbursements.last.net_amount.set net_amount
  @litigator_claim_form_page.disbursements.last.vat_amount.set vat_amount
end
