require 'sdl2'
require 'libnotify'
require 'concurrent-edge'

module Pomodoro
  class Notifier
    def initialize
      @mutex = Concurrent::Semaphore.new(1)

      SDL2::init(SDL2::INIT_AUDIO)
      SDL2::Mixer.init(SDL2::Mixer::INIT_OGG)
    end

    def ding!
      sound!
      libnotify!
    end

    def libnotify!
      Libnotify.show(:icon_path => 'gnome-break-timer', :summary => 'Timer done!')
    end

    def sound!
      @mutex.acquire
      SDL2::Mixer.open(44100)

      wave = SDL2::Mixer::Chunk.load('/usr/share/sounds/freedesktop/stereo/complete.oga')
      SDL2::Mixer::Channels.play(0, wave, 3)

      Concurrent::TimerTask.execute(:execution_interval => 1) do |task|
        return if SDL2::Mixer::Channels.play?(0)

        task.shutdown
        SDL2::Mixer.close
        @mutex.release
      end
    end
  end
end
