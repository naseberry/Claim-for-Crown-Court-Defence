namespace :data do
  namespace :migrate do

    desc 'Seed Disbursement Types'
    task :disbursement_types => :environment do
      load File.join(Rails.root, 'db', 'seeds', 'disbursement_types.rb')
    end

    desc 'set all admins to receive notification emails'
    task :set_notify => :environment do
      external_users = ExternalUser.admins
      external_users.each do |eu|
        eu.email_notification_of_message='true'
      end
    end

    desc 'Set fee types quantities to decimal for SPF, WPF, RNF, CAV, WOA'
    task :set_quantity_is_decimal => :environment do
      %w{ SPF WPF RNF RNL CAV WOA }.each do |code|
        recs = Fee::BaseFeeType.where(code: code).where.not(quantity_is_decimal: true)
        recs.each do |rec| rec.update(quantity_is_decimal: true)
          puts "Quantity is decimal set to TRUE for fee type #{code}"
        end
      end
    end

    desc 'softly delete Travel costs disbursement type'
    task :delete_travel_costs => :environment do
      dt = DisbursementType.where(name: 'Travel costs').first
      dt.deleted_at = Time.now
      dt.save!
    end

    desc 'Add Unique Code to Fee Types table'
    task :fee_type_unique_code => :environment do
      require File.join(Rails.root, 'lib', 'tasks', 'rake_helpers', 'fee_type_unique_code_adder')
      RakeHelpers::FeeTypeUniqueCodeAdder.new.run
    end

    desc 'Add Unique Code to Expense Types table'
    task :expense_type_unique_code => :environment do
      load File.join(Rails.root, 'db', 'seeds', 'expense_types.rb')
    end

    desc 'Add Unique Code to Disbursement Types table'
    task :disbursement_types_unique_code => :environment do
      load File.join(Rails.root, 'db', 'seeds', 'disbursement_types.rb')
    end

    desc 'Change fee type codes on case types to unique codes'
    task :case_type_codes => :environment do
      CaseType.all.each do |case_type|
        fee_type = Fee::BaseFeeType.where(code: case_type.fee_type_code).first
        case_type.fee_type_code = fee_type.unique_code
        case_type.save!
      end
    end


    desc 'Update the disbursement vat amount on all claims'
    task :vat => :environment do
      Claim::BaseClaim.connection.execute('UPDATE disbursements SET vat_amount = 0.0 WHERE vat_amount IS NULL')
      Claim::BaseClaim.connection.execute('UPDATE expenses SET vat_amount = 0.0 WHERE vat_amount IS NULL')
      claim_ids = Claim::BaseClaim.pluck(:id)
      num_claims = claim_ids.size
      claim_ids.each_with_index do |claim_id, i|
        begin
          puts "Updated #{i} claims" if i % 1000 == 0
          claim = Claim::BaseClaim.find(claim_id)
          claim.update_disbursements_total
          claim.update_expenses_total
          claim.update_fees_total
          claim.save!
        rescue => err
          puts ">>>> ERROR saving #{claim_id} >>>>> #{err.class} :: #{err.message} "
        end
      end
    end

    desc 'Run all outstanding data migrations'
    task :all => :environment do
      {
        'vat' => 'Recacalculate VAT totals for all claims',
      }.each do |task, comment|
        puts comment
        Rake::Task["data:migrate:#{task}"].invoke
      end
    end
  end
end

