require 'test/unit'

$:.unshift File.expand_path('../../lib', __FILE__)
require 'dsl_definition'

# Override the backtick command
# @todo option to call the old one? collect_system_calls = true?
module Kernel
  def `(cmd)
    "call #{cmd}"
  end
end

class TestConfig < Test::Unit::TestCase

  def setup
    super
    @dsl = DSL.new
  end

  def test_config_assigns
    s = @dsl.config :name do |conf|
      conf.name = 'Test'
      conf.file = '/dev/null'
      conf.needs_root = true
    end

    assert_equal(:name, s.id)
    assert_equal('Test', s.name)
    assert_equal('/dev/null', s.file)
    assert_equal(true, s.needs_root)
  end

  def test_service_assigns
    s = @dsl.service :name do |conf|
      conf.start = 'nonsense start'
      conf.stop = 'nonsense stop'
      conf.restart = 'nonsense restart'
    end

    assert_equal('nonsense start', s.start)
    assert_equal('nonsense stop', s.stop)
    assert_equal('nonsense restart', s.restart)
  end

  def test_run_nonsense
    s = @dsl.service :name do |conf|
      conf.start = 'nonsense start'
      conf.stop = 'nonsense stop'
      conf.restart = 'nonsense restart'
    end
  end
    # todo mock up system call


end