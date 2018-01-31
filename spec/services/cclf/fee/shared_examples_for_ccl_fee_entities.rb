shared_examples 'returns CCLF Litigator Fee bill (sub)type' do |code|
  before { allow(fee_type).to receive(:unique_code).and_return code }
  it 'returns CCLF Litigator Fee bill type' do
    is_expected.to eql 'LIT_FEE'
  end
end

shared_examples 'Litigator Fee Adapter' do |bill_scenario_mappings|
  let(:fee) { instance_double('fee') }
  let(:claim) { instance_double('claim', case_type: case_type) }
  let(:case_type) { instance_double('case_type') }
  let(:fee_type) { instance_double('fee_type') }

  before do
    allow(fee).to receive(:fee_type).and_return fee_type
    allow(fee).to receive(:claim).and_return claim
  end

  describe '#bill_type' do
    bill_scenario_mappings.keys.each do |code|
      context "for #{code} fee type" do
        subject { described_class.new(fee).bill_type }
        include_examples 'returns CCLF Litigator Fee bill (sub)type', code
      end
    end
  end

  describe '#bill_subtype' do
    bill_scenario_mappings.keys.each do |code|
      context "for #{code} fee type" do
        subject { described_class.new(fee).bill_subtype }
        include_examples 'returns CCLF Litigator Fee bill (sub)type', code
      end
    end
  end

  describe '#bill_scenario' do
    bill_scenario_mappings.each do |code, scenario|
      context "for #{code} fee type" do
        subject { described_class.new(fee).bill_scenario }

        before do
          allow(fee_type).to receive(:unique_code).and_return code
          allow(case_type).to receive(:fee_type_code).and_return code
        end

        it "returns CCLF Litigator Fee scenario #{scenario}" do
          is_expected.to eql scenario
        end
      end
    end
  end
end
