module SlackLogger
  class PostMessage
    def self.call(**args)
      new(**args).call
    end

    attr_reader :text, :channel, :attachments

    def initialize(text:, channel: SlackLogger.config.channel, attachments: [])
      @text = text
      @channel = channel
      @attachments = attachments
    end

    def call
      client.chat_postMessage channel: channel, text: text, attachments: attachments
    end

    private

    def client
      Slack::Web::Client.new(token: SlackLogger.config.token)
    end
  end
end
