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

    def ping(task, error)
      PostMessage.call text: "*#{error.class}* (_#{task.name}_)",
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
