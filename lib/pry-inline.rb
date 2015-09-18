require 'pry'
require 'ripper'
require 'set'

require 'pry-inline/code_extension'
require 'pry-inline/parser'

Pry.config.hooks.add_hook(:when_started, :pry_inline) do
  Pry::Code.send(:prepend, PryInline::CodeExtension)
end

before_session_hooks = Pry.config.hooks.get_hooks(:before_session)
Pry.config.hooks.delete_hooks(:before_session)

begin
  Pry.config.hooks.add_hook(:before_session, :pry_inline) do |_, target, _|
    PryInline::CodeExtension.current_binding = target
  end
ensure
  before_session_hooks.each do |name, callable|
    Pry.config.hooks.add_hook(:before_session, name, callable)
  end
end

module PryInline
end
