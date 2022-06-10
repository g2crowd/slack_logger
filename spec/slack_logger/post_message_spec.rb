require 'spec_helper'

RSpec.describe SlackLogger::PostMessage do
  subject(:logger) { described_class.new(text: text, channel: channel) }

  let(:text) { 'Message from bot' }
  let(:environment) { nil }
  let(:channel) { '#foobar' }
  let(:ruby_logger) { Logger.new(IO::NULL) }

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
        SlackLogger.configure do |c| 
          c.env = environment
          c.enabled = proc { true }
          c.logger = ruby_logger
        end
      end

      [
        nil,
        'production'
      ].each do |env|
        context "when env is #{env.inspect}" do
          let(:environment) { env }

          it 'posts message' do
            logger.call
            expect(client).to have_received(:chat_postMessage).with(channel: channel, text: text, attachments: [])
          end
        end
      end

      context "when env is nil" do
        context 'when channel does not exist' do
          before do
            allow(client).to receive(:chat_postMessage).and_raise(Slack::Web::Api::Errors::ChannelNotFound.new('boom'))
            allow(ruby_logger).to receive(:warn)
          end

          it 'does not raise' do
            expect { logger.call }.not_to raise_error
          end

          it 'logs a warning' do
            logger.call
            expect(ruby_logger).to have_received(:warn)
          end
        end
      end

      context "when env is production" do
        let(:environment) { 'production' }

        context 'when channel does not exist' do
          before do
            allow(client).to receive(:chat_postMessage).and_raise(Slack::Web::Api::Errors::ChannelNotFound.new('boom'))
          end

          it 'raises error' do
            expect { logger.call }.to raise_error(Slack::Web::Api::Errors::ChannelNotFound)
          end
        end
      end

      {
        'development' => 'dev',
        'staging' => 'stg',
        'test' => 'test',
        'foo' => 'foo'
      }.each do |env, suffix|
        context "when env is non-production and is #{env.inspect}" do
          let(:environment) { env }

          it "posts message to channel suffixed with '#{SlackLogger::PostMessage::CHANNEL_SUFFIX_DELIMITER}#{suffix}'" do
            logger.call
            expect(client).to have_received(:chat_postMessage).with(
              channel: "#{channel}#{SlackLogger::PostMessage::CHANNEL_SUFFIX_DELIMITER}#{suffix}", 
              text: text, 
              attachments: []
            )
          end

          context 'when channel does not exist' do
            before do
              allow(client).to receive(:chat_postMessage).and_raise(Slack::Web::Api::Errors::ChannelNotFound.new('boom'))
              allow(ruby_logger).to receive(:warn)
            end

            it 'does not raise' do
              expect { logger.call }.not_to raise_error
            end

            it 'logs a warning' do
              logger.call
              expect(ruby_logger).to have_received(:warn)
            end
          end
        end
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
