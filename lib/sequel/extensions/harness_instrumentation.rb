require 'active_support/core_ext/module'
require 'logger'

module Sequel
  class Database
    class NullLogger < Logger
      def initialize(*args)

      end

      def add(*args)

      end
    end

    def null_logger
      @null_logger ||= NullLogger.new
    end

    def log_yield_with_instrument(sql, args = nil, &block)
      @loggers << null_logger if @loggers.empty?
      log_yield_without_instrument sql, args, &block
    end
    alias_method_chain :log_yield, :instrument

    def log_duration_with_instrumentation(time, sql)
      duration = time / 1000

      Harness.increment 'sequel.query'
      Harness.timing 'sequel.query', duration

      op = sql[0..5]
      case op
      when 'SELECT'
        Harness.increment 'sequel.select'
        Harness.timing 'sequel.select', duration
        Harness.increment 'sequel.read'
        Harness.timing 'sequel.read', duration
      when 'UPDATE'
        Harness.increment 'sequel.update'
        Harness.timing 'sequel.update', duration
        Harness.increment 'sequel.write'
        Harness.timing 'sequel.write', duration
      when 'INSERT'
        Harness.increment 'sequel.insert'
        Harness.timing 'sequel.insert', duration
        Harness.increment 'sequel.write'
        Harness.timing 'sequel.write', duration
      when 'DELETE'
        Harness.increment 'sequel.delete'
        Harness.timing 'sequel.delete', duration
        Harness.increment 'sequel.write'
        Harness.timing 'sequel.write', duration
      end

      log_duration_without_instrumentation duration, sql
    end
    alias_method_chain :log_duration, :instrumentation
  end
end
