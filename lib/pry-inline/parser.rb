require 'ripper'

module PryInline
  class Parser < Ripper
    attr_reader :ret

    def self.sexp(src, filename = '-', lineno = 1)
      parser = Parser.new(src, filename, lineno)
      parser.parse || parser.ret
    end

    Ripper::PARSER_EVENTS.each do |event|
      next if event == :parse_error # A custom handler is provided below

      module_eval(<<-End, __FILE__, __LINE__ + 1)
        def on_#{event}(*args)
          args.unshift :#{event}
          @ret = args
        end
      End
    end

    Ripper::SCANNER_EVENTS.each do |event|
      module_eval(<<-End, __FILE__, __LINE__ + 1)
        def on_#{event}(tok)
          @ret = [:@#{event}, tok, [lineno(), column()]]
        end
      End
    end

    def compile_error(_)
      @ret
    end

    def on_parse_error(_)
      @ret
    end
  end
end
