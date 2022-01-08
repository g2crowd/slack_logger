require 'spec_helper'
require 'rake'

RSpec.describe SlackLogger do
  let(:task) { instance_double(Rake::Task, name: 'refresh') }
  let(:block) { proc { nil } }
  let(:reporter) { instance_double SlackLogger::ReportFailure, call: true }

  describe '::report_failure' do
    it 'delegates to reporter' do
      allow(SlackLogger::ReportFailure).to receive(:new).and_return(reporter)
      described_class.report_failure(task, &block)
      expect(SlackLogger::ReportFailure).to have_received(:new).with(task, block)
      expect(reporter).to have_received(:call)
    end
  end
end
