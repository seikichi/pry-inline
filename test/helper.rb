# coding: UTF-8

require 'coveralls'
Coveralls.wear!

module TerminalWidthExtension
  def self.terminal_width
    @width
  end

  def self.terminal_width=(width)
    @width = width
  end

  def terminal_width
    TerminalWidthExtension.terminal_width
  end
end

begin
  if ENV['COVERAGE']
    require 'simplecov'
    SimpleCov.start do
      add_filter '/test/'
    end
  end
rescue LoadError
end
