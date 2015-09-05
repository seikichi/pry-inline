require 'pry'
require 'ripper'
require 'set'

require 'pry-inline/when_started_hook'
require 'pry-inline/before_session_hook'

Pry.config.hooks
  .add_hook(:when_started, :pry_inline, PryInline::WhenStartedHook.new)

before_session_hooks = Pry.config.hooks.get_hooks(:before_session)
Pry.config.hooks.delete_hooks(:before_session)

begin
  Pry.config.hooks.add_hook(:before_session, :pry_inline, PryInline::BeforeSessionHook.new)
ensure
  before_session_hooks.each do |name, callable|
    Pry.config.hooks.add_hook(:before_session, name, callable)
  end
end

module PryInline
end
