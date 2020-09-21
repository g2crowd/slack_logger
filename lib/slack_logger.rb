require 'slack_logger/version'
require 'slack_logger/report_failure'
require 'slack_logger/configuration'

module SlackLogger
  def self.report_failure(task, &block)
    SlackLogger::ReportFailure.new(task, block).call
  end

  def self.config
    @config ||= SlackLogger::Configuration.new
  end

  def self.configure
    yield config
  end
end
