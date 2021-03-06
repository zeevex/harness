require 'moped/instrumentable'

module Moped
  module Instrumentable
    class Log
      class << self
        def instrument_with_notifications(name, payload = {}, &block)
          ActiveSupport::Notifications.instrument "moped.operation", payload.merge(timer: true, counter: true), &block
        end
        alias_method_chain :instrument, :notifications
      end
    end
  end
end

ActiveSupport::Notifications.subscribe "moped.operation" do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  op = event.payload.fetch(:ops).first

  case op.op_code
  when 2004
    Harness.increment 'moped.query'
    Harness.timing 'moped.query', event.duration
    Harness.increment 'moped.read'
    Harness.timing 'moped.read', event.duration
  when 2002
    Harness.increment 'moped.insert'
    Harness.timing 'moped.insert', event.duration
    Harness.increment 'moped.write'
    Harness.timing 'moped.write', event.duration
  when 2001
    Harness.increment 'moped.update'
    Harness.timing 'moped.update', event.duration
    Harness.increment 'moped.write'
    Harness.timing 'moped.write', event.duration
  when 2006
    Harness.increment 'moped.remove'
    Harness.timing 'moped.remove', event.duration
    Harness.increment 'moped.write'
    Harness.timing 'moped.write', event.duration
  end
end
