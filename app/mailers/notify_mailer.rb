class NotifyMailer < GovukNotifyRails::Mailer
  # Define methods as usual, and set the template and personalisation accordingly
  # Then just use mail() as with any other ActionMailer, with the recipient email.
  # This is just an example:
  #
  def message_added_email(claim)
    user = claim.creator.user

    set_template(Settings.govuk_notify.templates.message_added_email)
    set_personalisation(
      user_name: user.name,
      claim_case_number: claim.case_number,
      claim_url: external_users_claim_url(claim, messages: true),
      edit_user_url: edit_external_users_admin_external_user_url(user)
    )
    mail(to: user.email)
  end

  def send_email_if_required(claim)
    return unless current_user.persona.is_a?(CaseWorker)
    return unless claim.creator.send_email_notification_of_message?
    return if claim.creator.softly_deleted?
    NotifyMailer.message_added_email(claim).deliver_later
  end
end
