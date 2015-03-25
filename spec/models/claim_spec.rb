require 'rails_helper'

RSpec.describe Claim, type: :model do
  it { should belong_to(:advocate) }

  it { should have_many(:case_worker_claims) }
  it { should have_many(:case_workers) }

  it { should validate_presence_of(:advocate) }
end
