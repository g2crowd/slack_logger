require 'spec_helper'
require 'rake'

RSpec.describe SlackLogger::ReportFailure do
  subject(:reporter) { described_class.new(task, block) }

  let(:task) { instance_double(Rake::Task, name: 'refresh') }
  let(:client) { instance_double(Slack::Web::Client) }

  before do
    allow(Slack::Web::Client).to receive(:new).and_return(client)
    allow(client).to receive(:chat_postMessage)
  end

  after do
    SlackLogger.configure { |c| c.enabled = nil }
  end

  describe '#call' do
    context 'when block does not raise error' do
      let(:block) { proc { nil } }

      it 'does not send a message' do
        reporter.call
        expect(client).not_to have_received(:chat_postMessage)
      end
    end

    context 'when block raises error and config is enabled' do
      let(:block) { proc { raise ArgumentError } }

      before do
        SlackLogger.configure { |c| c.enabled = proc { true } }
      end

      it 'sends a message to slack' do
        expect { reporter.call }.to raise_error ArgumentError
        expect(client).to have_received(:chat_postMessage)
      end
    end

    context 'when block raises error and config is disabled' do
      let(:block) { proc { raise ArgumentError } }

      before do
        SlackLogger.configure { |c| c.enabled = proc { false } }
      end

      it 'sends a message to slack' do
        expect { reporter.call }.to raise_error ArgumentError
        expect(client).not_to have_received(:chat_postMessage)
      end
    end
  end
end
