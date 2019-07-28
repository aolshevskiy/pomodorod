require 'pomodoro'
require 'optparse'
require 'dbus'

module Pomodoro::Main
  class Client
    def self.main
      new(*ARGV).execute
    end

    def execute
      case @cmd
        when 'in'
          start(*@args)
        when 'cs', 'continuous-state'
          continuous_state
        when 's', 'state'
          state
        when 't', 'toggle'
          @service.Toggle
        when 'r', 'reset'
          @service.Reset
      end
    end

    private

    def initialize(cmd, *args)
      bus = DBus::SessionBus.instance
      @service = bus.service('aolshev.pomodorod').object('/aolshev/Pomodorod')
      @service.introspect

      @cmd = cmd
      @args = args
    end

    def start(duration_str)
      duration = parse_duration(duration_str)
      @service.Start(duration)
    end

    def continuous_state
      while true
        state
        STDOUT.flush
        sleep(1)
      end
    end

    def state
      state, time_left = @service.State
      result = case state
        when 'running'
          result = format_duration_secs(time_left)
        when 'paused'
          result = 'P ' + format_duration_secs(time_left)
        when 'empty'
          result = ' '
      end
      puts result
    end

    def format_duration_secs(duration)
      Time.at(duration).utc.strftime("%M:%S")
    end

    def parse_duration(duration_str)
      case duration_str
        when /^(\d+)m$/
          $1.to_i * 60
        when /^(\d+)s$/
          $1.to_i      
        else
          raise ArgumentError, "Unknown format: #{duration_str}"
      end
    end
  end
end
