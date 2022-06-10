module SlackLogger
  class PostMessage
    CHANNEL_SUFFIX_DELIMITER = '-'.freeze

    ENV_CHANNEL_SUFFIX_MAPPING =
    {
      nil => '',
      production: '',
      development: "#{CHANNEL_SUFFIX_DELIMITER}dev",
      staging: "#{CHANNEL_SUFFIX_DELIMITER}stg"
    }.freeze

    def self.call(**args)
      new(**args).call
    end

    attr_reader :text, :channel, :attachments

    def initialize(text:, channel: SlackLogger.config.channel, attachments: [])
      @text = text
      @channel = env_channel(channel)
      @attachments = attachments
    end

    def call
      do_call
    rescue Slack::Web::Api::Errors::ChannelNotFound
      raise if SlackLogger.config.production?
      logger.warn "attempt to send to non-existent slack channel #{channel.inspect}"
    end

    private

    def do_call
      return unless SlackLogger.config.enabled.call(channel: channel, text: text)
      client.chat_postMessage channel: channel, text: text, attachments: attachments
    end

    def client
      Slack::Web::Client.new(token: SlackLogger.config.token)
    end

    def env_channel(channel)
      "#{channel}#{ENV_CHANNEL_SUFFIX_MAPPING[env] || "#{CHANNEL_SUFFIX_DELIMITER}#{env}"}"
    end

    def env
      SlackLogger.config.env
    end

    def logger
      @logger ||= SlackLogger.config.logger || Logger.new(IO::NULL)
    end
  end
end
