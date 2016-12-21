require 'rails_helper'
require 'caching/api_request'

describe Caching::ApiRequest do
  let(:url) { 'http://test.com/ping.json' }

  let(:value1) { 'test value 1' }
  let(:response1) { double('Response1', headers: {}, body: value1) }
  let(:value2) { 'test value 2' }
  let(:response2) { double('Response2', headers: {}, body: value2) }

  before(:each) do
    Caching.backend = Caching::MemoryStore
  end

  after(:each) do
    Caching.clear
  end

  describe 'options' do
    subject { described_class.new(url, options) }

    context 'default set' do
      let(:options) { {} }

      it 'should have a default set of options, if none provided' do
        expect(subject.options[:ttl]).to eq(900)
        expect(subject.options[:ignore_params]).to eq([])
      end
    end

    context 'custom set' do
      let(:options) { {ttl: 180, ignore_params: ['sorting']} }

      it 'should override default options if provided' do
        expect(subject.options[:ttl]).to eq(180)
        expect(subject.options[:ignore_params]).to eq(['sorting'])
      end
    end
  end

  describe 'url normalization and param filtering' do
    [
      %w(http://test.com                http://test.com),
      %w(http://Test.Com                http://test.com),
      %w(http://test.com?               http://test.com),
      %w(http://test.com/               http://test.com/),
      %w(http://test.com/?              http://test.com/),
      %w(http://test.com?123            http://test.com?123),
      %w(http://test.com/?123           http://test.com/?123),
      %w(http://test.com/?321           http://test.com/?321),
      %w(http://test.com?test=1         http://test.com?test=1),
      %w(http://test.com?api_key=1      http://test.com?api_key=1),
      %w(http://test.com?api_key=1&a=b  http://test.com?a=b&api_key=1),
      %w(http://test.com?b=1&a=2        http://test.com?a=2&b=1),
      %w(http://test.com?a=1#anchor     http://test.com?a=1),
    ].each do |(url, processed_url)|
      it "should process #{url} and return #{processed_url}" do
        instance = described_class.new(url)
        expect(instance.url).to eq(processed_url)
      end
    end
  end

  describe 'writing and reading from the cache' do
    let(:current_store) { Caching.backend.current }

    context 'caching new content' do
      it 'should write to the cache and return the content' do
        expect(current_store).to receive(:set).with(/api:/, /test value 1/).once.and_call_original
        returned = described_class.cache(url) { response1 }
        expect(returned).to eq(value1)
      end

      it 'should cache again a stale content' do
        Timecop.freeze(1.day.ago) do
          returned = described_class.cache(url) { response1 }
          expect(returned).to eq(value1)
        end

        returned = described_class.cache(url) { response2 }
        expect(returned).to eq(value2)
      end
    end

    context 'reading from cache existing content' do
      it 'should read from the cache and return the content' do
        expect(current_store).to receive(:set).with(/api:/, /test value 1/).once.and_call_original
        expect(current_store).not_to receive(:set).with(/api:/, /test value 2/)
        expect(current_store).to receive(:get).with(/api:/).twice.and_call_original

        returned_1 = described_class.cache(url) { response1 }
        returned_2 = described_class.cache(url) { response2 }

        expect(returned_1).to eq(returned_2)
      end
    end
  end
end