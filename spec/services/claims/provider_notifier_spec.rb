require 'rails_helper'

RSpec.describe Claims::ProviderNotifier do
  let(:creator) { create(:external_user, :with_email_notification_of_messages) }
  let(:claim) { create(:claim, external_user: creator) }

  context 'when the creator of the claim is not an active user' do
    let(:creator) { create(:external_user, :with_email_notification_of_messages, :softly_deleted) }

    it 'does not notify the provider' do
      expect(NotifyMailer).not_to receive(:message_added_email)
      described_class.call(claim)
    end
  end

  context 'when the creator is configured not to receive email notifications' do
    let(:creator) { create(:external_user, :without_email_notification_of_messages) }

    it 'does not notify the provider' do
      expect(NotifyMailer).not_to receive(:message_added_email)
      described_class.call(claim)
    end
  end

  context 'when the creator is active and configured to receive email notifications' do
    let(:creator) { create(:external_user, :with_email_notification_of_messages) }
    let(:mock_mailer) { double(:mailer) }

    it 'does notify the provider' do
      expect(NotifyMailer).to receive(:message_added_email).with(claim).and_return(mock_mailer)
      expect(mock_mailer).to receive(:deliver_later)
      described_class.call(claim)
    end
  end
end
