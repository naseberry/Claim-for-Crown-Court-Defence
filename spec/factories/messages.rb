# == Schema Information
#
# Table name: messages
#
#  id                      :integer          not null, primary key
#  body                    :text
#  claim_id                :integer
#  sender_id               :integer
#  created_at              :datetime
#  updated_at              :datetime
#  attachment_file_name    :string
#  attachment_content_type :string
#  attachment_file_size    :integer
#  attachment_updated_at   :datetime
#

FactoryBot.define do
  factory :message do
    body { Faker::Lorem.paragraph }
    claim

    after(:build) do |message|
      message.sender_id ||= (message.sender || create(:user, email: Faker::Internet.email, password: 'password', password_confirmation: 'password')).id
    end
  end

  factory :unpersisted_message, class: Message do
    body            { Faker::Lorem.paragraph }
    claim           { FactoryBot.build :unpersisted_claim }
    sender          { FactoryBot.build :user }
  end

  trait :with_attachment do
    attachment { File.open(Rails.root + 'features/examples/shorter_lorem.docx') }
    attachment_content_type { 'application/msword' }
  end
end
