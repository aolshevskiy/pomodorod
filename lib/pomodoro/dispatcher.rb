require 'concurrent-edge'
require 'dbus'

module Pomodoro
  class Dispatcher < Concurrent::Actor::Context
    def initialize(notifier)
      @notifier = notifier

      @state = :empty
      @deadline = nil
      @time_left = nil
      @scheduled_task = nil
    end

    def on_message(args_list)
      cmd, *args = args_list
      case cmd
      when :start
        start(*args)
      when :reset
        reset!
      when :pause
        pause!
      when :toggle
        toggle!
      when :resume
        resume!
      when :state
        state
      else
        raise ArgumentError, "Unknown cmd: #{cmd}"
      end
    end

    private

    def reset!
      @deadline = nil
      @scheduled_task.cancel unless @scheduled_task.nil?
      @scheduled_task = nil
      @state = :empty
    end

    def start(duration)
      reset!
      
      @deadline = Time.now.to_f + duration
      @scheduled_task = Concurrent::ScheduledTask.execute(duration) do
        @notifier.ding!
        self << [:reset]
      end
      @state = :running

      nil
    end

    def pause!
      return if [:empty, :paused].include? @state

      case @state
      when :running
        @time_left = @deadline - Time.now.to_f
        @deadline = nil
        @scheduled_task.cancel
        @state = :paused
      else
        unknown_state
      end
    end

    def resume!
      return if [:empty, :running].include? @state

      case @state
      when :paused
        start(@time_left)
        @time_left = nil
      else
        unknown_state
      end
    end

    def toggle!
      return if state == :empty

      case @state
      when :paused
        resume!
      when :running
        pause!
      else
        unknown_state
      end
    end

    def state
      case @state
      when :empty
        [@state, 0]
      when :running
        [@state, @deadline - Time.now.to_f]
      when :paused
        [@state, @time_left]
      else
        unknown_state
      end
    end

    def unknown_state
      raise ScriptError, "Unknown state: #{@state}"
    end
  end
end
