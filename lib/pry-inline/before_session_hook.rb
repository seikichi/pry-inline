require 'pry-inline/inline_debuggable_loc'

module PryInline
  class BeforeSessionHook
    def call(_, target, pry)
      return if target.eval('self') == Pry.main
      PryInline::InlineDebuggableLOC.binding = target
      pry.run_command('whereami')
      PryInline::InlineDebuggableLOC.binding = nil
    end
  end
end
