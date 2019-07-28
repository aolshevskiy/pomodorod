require 'dbus'

module Pomodoro

  class BusController < DBus::Object
    def initialize(dispatcher)
      super('/aolshev/Pomodorod')
      @dispatcher = dispatcher
    end

    dbus_interface 'aolshev.Pomodorod' do
      dbus_method :Start, 'in duration:i' do |duration|
        start_timer(duration)
      end
      dbus_method :Reset, '' do
        @dispatcher << [:reset]
      end
      dbus_method :Pause, '' do
        @dispatcher << [:pause]
      end
      dbus_method :Resume, '' do
        @dispatcher << [:resume]
      end
      dbus_method :Toggle, '' do
        @dispatcher << [:toggle]
      end
      dbus_method :State, 'out state:s, out time_left:d' do
        s, time_left = state
        [s.to_s, time_left]
      end
    end

    private

    def start_timer(duration_seconds)
      @dispatcher << [:start, duration_seconds]
    end

    def state
      future = @dispatcher.ask([:state])
      raise TimeoutError unless future.wait(0.1)
      future.value
    end
  end
end
