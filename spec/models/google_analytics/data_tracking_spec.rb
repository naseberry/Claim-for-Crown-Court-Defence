require 'rails_helper'

module GoogleAnalytics

  describe DataTracking do
    context '#enabled?' do
      before do
        allow(Rails).to receive(:env).and_return('production'.inquiry)
      end

      context 'with an adapter set' do
        before do
          allow(described_class).to receive(:adapter).and_return('Adapter')
        end

        %w(staging gamma).each do |host|
          it "returns true when host is #{host}" do
            allow(RailsHost).to receive(:env).and_return(host)
            expect(described_class.enabled?).to be_truthy
          end
        end

        it 'returns false when host is demo' do
          allow(RailsHost).to receive(:env).and_return('demo')
          expect(described_class.enabled?).to be_falsey
        end
      end

      context 'with no adapter set' do
        before do
          allow(described_class).to receive(:adapter).and_return(nil)
        end

        it 'returns false when host is demo' do
          allow(RailsHost).to receive(:env).and_return('gamma')
          expect(described_class.enabled?).to be_falsey
        end
      end
    end
  end
end