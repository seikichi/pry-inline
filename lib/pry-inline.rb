require 'pry'
require 'ripper'
require 'set'

require 'pry-inline/when_started_hook'
require 'pry-inline/before_session_hook'

Pry.config.hooks
  .add_hook(:when_started, :pry_inline, PryInline::WhenStartedHook.new)
  .add_hook(:before_session, :pry_inline, PryInline::BeforeSessionHook.new)

module PryInline
end
