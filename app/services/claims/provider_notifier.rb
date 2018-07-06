module Claims
  class ProviderNotifier
    def self.call(claim)
      new(claim).call
    end

    def initialize(claim)
      @claim = claim
      @creator = claim.creator
    end

    def call
      return if creator.softly_deleted?
      return unless creator&.send_email_notification_of_message?
      NotifyMailer.message_added_email(claim).deliver_later
    end

    private

    attr_reader :claim, :creator
  end
end
