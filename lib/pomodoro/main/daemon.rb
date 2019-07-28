require 'pomodoro/bus_controller'
require 'pomodoro/notifier'
require 'pomodoro/dispatcher'
require 'pomodoro/main/daemon'

include Pomodoro

module Pomodoro::Main

  class Daemon
    def initialize
      session_bus = DBus.session_bus
      service = session_bus.request_service('aolshev.pomodorod')

      notifier = Notifier.new
      dispatcher = Dispatcher.spawn(:dispatcher, notifier)

      bus_controller = BusController.new(dispatcher)
      service.export(bus_controller)

      @loop = DBus::Main.new
      @loop << session_bus
    end

    def run
      @loop.run
    end
  end
end
