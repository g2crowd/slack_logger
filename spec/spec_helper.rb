require 'simplecov'
SimpleCov.start do
  add_filter %w(/spec/)
  enable_coverage :branch
  primary_coverage :branch
end

require 'bundler/setup'
require 'slack_logger'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
