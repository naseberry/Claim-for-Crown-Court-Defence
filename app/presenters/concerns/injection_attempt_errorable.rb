module InjectionAttemptErrorable
  extend ActiveSupport::Concern

  included do
    def injection_error
      messages = injection_errors
      return unless messages.present?
      message = injection_error_header(messages)
      yield(message) if block_given?
      message
    end
    alias_method :injection_error_summary, :injection_error

    def injection_errors
      last_attempt = claim.injection_attempts&.last
      last_attempt&.error_messages if last_attempt&.active?
    end

    def injection_error_header(messages)
      suffix = I18n.t(:error, scope: %i[shared injection_errors])
      "#{messages.size} #{suffix.pluralize(messages.size)}"
    end
    private :injection_error_header
  end
end