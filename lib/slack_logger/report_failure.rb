require 'slack-ruby-client'

module SlackLogger
  class ReportFailure
    attr_reader :task, :block

    def initialize(task, block)
      @task = task
      @block = block
    end

    def call
      block.call
    rescue StandardError => e
      ping(task, e) if SlackLogger.config.enabled.call(e)
      raise e
    end

    private

    def slack_notifier
      Slack::Web::Client.new(token: SlackLogger.config.token)
    end

    def ping(task, error)
      slack_notifier.chat_postMessage channel: SlackLogger.config.channel,
                                      text: "*#{error.class}* (_#{task.name}_)",
                                      attachments: [
                                        {
                                          fallback: error.message,
                                          color: 'danger',
                                          fields: [
                                            { title: 'message', value: error.message },
                                            { title: 'backtrace', value: error.backtrace.join("\n") }
                                          ]
                                        }
                                      ]
    end
  end
end
