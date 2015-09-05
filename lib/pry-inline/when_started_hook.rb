require 'pry-inline/inline_debuggable_code'
require 'pry-inline/inline_debuggable_loc'

module PryInline
  class WhenStartedHook
    def call(_, _, _)
      Pry::Code.send(:prepend, PryInline::InlineDebuggableCode)
      Pry::Code::LOC.send(:prepend, PryInline::InlineDebuggableLOC)
    end
  end
end
