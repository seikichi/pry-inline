# coding: UTF-8

require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter,
]
SimpleCov.start do
  add_filter 'test'
end

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
