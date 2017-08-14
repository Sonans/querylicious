# frozen_string_literal: true

require 'rspec'
require 'rspec-parameterized'
require 'querylicious'

RSpec.configure do |config|
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.filter_run_when_matching :focus

  config.expect_with :rspec do |c|
    c.syntax = :expect
    c.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.profile_examples = 10
end

RSpec::Matchers.define :be_a_kv_pair do
  match do |thing|
    thing.is_a? Querylicious::KeyValuePair
  end
end

RSpec::Matchers.define :have_size do |expected|
  match do |arr|
    @actual = arr.size
    values_match? expected, @actual
  end

  diffable
end
