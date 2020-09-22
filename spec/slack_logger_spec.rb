require 'spec_helper'
require 'rake'

RSpec.describe SlackLogger do
  let(:task) { instance_double(Rake::Task, name: 'refresh') }
  let(:client) { instance_double(Slack::Web::Client) }

  before do
    allow(Slack::Web::Client).to receive(:new).and_return(client)
    allow(client).to receive(:chat_postMessage)
  end

  describe '::report_failure' do
    context 'when block does not raise error' do
      it 'does not send a message' do
        described_class.report_failure(task) {}
        expect(client).not_to have_received(:chat_postMessage)
      end
    end

    context 'when block raises error and config is enabled' do
      before do
        allow(described_class.config.enabled).to receive(:call).and_return(true)
      end

      # rubocop:disable RSpec/MultipleExpectations
      it 'sends a message to slack' do
        expect { described_class.report_failure(task) { raise ArgumentError } }.to raise_error ArgumentError
        expect(client).to have_received(:chat_postMessage)
      end
      # rubocop:enable RSpec/MultipleExpectations
    end

    context 'when block raises error and config is disabled' do
      before do
        allow(described_class.config.enabled).to receive(:call).and_return(false)
      end

      # rubocop:disable RSpec/MultipleExpectations
      it 'sends a message to slack' do
        expect { described_class.report_failure(task) { raise ArgumentError } }.to raise_error ArgumentError
        expect(client).not_to have_received(:chat_postMessage)
      end
      # rubocop:enable RSpec/MultipleExpectations
    end
  end
end
