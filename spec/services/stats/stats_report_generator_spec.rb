require 'rails_helper'

RSpec.describe Stats::StatsReportGenerator, type: :service do
  describe '.call' do
    subject(:call_report_generator) { described_class.call(report_type) }

    let(:report_type) { 'management_information' }

    context 'when the report type is not valid' do
      let(:report_type) { 'some-report-type' }

      before { allow(Settings).to receive(:notify_report_errors).and_return(false) }

      it 'raises an invalid report type error' do
        expect { call_report_generator }.to raise_error(Stats::StatsReportGenerator::InvalidReportType)
      end

      it 'does not create a new report' do
        expect { call_report_generator rescue nil }.not_to change { Stats::StatsReport.count }.from(0)
      end
    end

    context 'when there is already a report of that type in progress' do
      before { Stats::StatsReport.create(report_name: report_type, status: 'started', report: 'some content') }

      it 'does not create a new report' do
        expect { call_report_generator }.not_to change { Stats::StatsReport.count }.from(1)
      end
    end

    context 'when there is no report of that type in progress' do
      let(:mocked_result) { Stats::Result.new('some new content', 'csv') }

      before { allow(Stats::ManagementInformationGenerator).to receive(:call).and_return(mocked_result) }

      it 'adds a new completed report' do
        expect { call_report_generator }
          .to change(Stats::StatsReport.where(report_name: report_type).completed, :count).by 1
      end

      it 'puts data into the new report' do
        call_report_generator
        new_record = Stats::StatsReport.where(report_name: report_type).completed.last
        file_path = ActiveStorage::Blob.service.path_for(new_record.document.blob.key)
        expect(File.open(file_path).read).to eq('some new content')
      end
    end

    context 'when an error happens during the generation of the report' do
      before do
        allow(Stats::ManagementInformationGenerator).to receive(:call).and_raise(StandardError)
      end

      it 'raises the error' do
        expect { call_report_generator }.to raise_error(StandardError)
      end

      it 'creates a new report marked as errored' do
        expect {
          call_report_generator rescue nil
        }.to change { Stats::StatsReport.where(report_name: report_type).errored.count }.from(0).to(1)
      end

      context 'when the error notifications are enabled' do
        before do
          allow(Settings).to receive(:notify_report_errors).and_return(true)
        end

        it 'sends an error notification' do
          allow(ActiveSupport::Notifications).to receive(:instrument)
          call_report_generator rescue nil
          record = Stats::StatsReport.where(report_name: report_type).errored.first
          args = ['call_failed.stats_report', id: record.id, name: report_type, error: instance_of(StandardError)]
          expect(ActiveSupport::Notifications).to have_received(:instrument).with(*args)
        end
      end

      context 'when the error notifications are disabled' do
        before do
          allow(Settings).to receive(:notify_report_errors).and_return(false)
          allow(ActiveSupport::Notifications).to receive(:instrument)
        end

        it 'does not send an error notification' do
          call_report_generator rescue nil
          expect(ActiveSupport::Notifications).not_to have_received(:instrument)
        end
      end
    end
  end
end
