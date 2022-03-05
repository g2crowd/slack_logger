require 'spec_helper'

RSpec.describe SlackLogger::PostMessage do
  subject(:logger) { described_class.new(text: text, channel: channel) }

  let(:text) { 'Message from bot' }
  let(:channel) { '#foobar' }

  let(:client) { instance_double Slack::Web::Client }

  before do
    allow(Slack::Web::Client).to receive(:new).and_return(client)
    allow(client).to receive(:chat_postMessage)
  end

  after do
    SlackLogger.configure { |c| c.enabled = nil }
  end

  describe '#call' do
    context 'when enabled' do
      before do
        SlackLogger.configure { |c| c.enabled = proc { true } }
      end

      it 'posts message' do
        logger.call
        expect(client).to have_received(:chat_postMessage).with(channel: channel, text: text, attachments: [])
      end
    end

    context 'when disabled' do
      before do
        SlackLogger.configure { |c| c.enabled = proc { false } }
      end

      it 'does not post message' do
        logger.call
        expect(client).not_to have_received(:chat_postMessage)
      end
    end
  end
end
