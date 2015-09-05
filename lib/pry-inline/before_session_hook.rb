require 'pry-inline/inline_debuggable_loc'

module PryInline
  class BeforeSessionHook
    def call(_, target, _)
      PryInline::InlineDebuggableLOC.binding = target
    end
  end
end
