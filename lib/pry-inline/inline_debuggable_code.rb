module PryInline
  # monkey patch for Pry::Code
  module InlineDebuggableCode
    def initialize(lines, start_line, code_type)
      super(lines, start_line, code_type)

      @lineno_to_variables = Hash.new { |h, k| h[k] = Set.new }
      traverse_sexp(Ripper.sexp(lines.is_a?(String) ? lines : lines.join("\n")))
      @lineno_to_variables.each do |lineno, variables|
        next if lineno == 0 || @lines.length <= lineno
        @lines[lineno - 1].variables = variables
      end
    end

    def with_marker(lineno = 1)
      super.tap do
        @lines.each do |line|
          line.variables = nil if line.lineno >= lineno
        end
      end
    end

    private

    def traverse_sexp(sexp)
      return unless sexp.is_a?(Array)
      event = sexp[0]

      return sexp.each { |s| traverse_sexp(s) } if event.is_a?(Array)
      return traverse_sexp_in_assignment(sexp[1]) if %i(assign massign params).include?(event)
      traverse_sexp(sexp[1..sexp.length]) unless event.to_s.start_with?('@')
    end

    def traverse_sexp_in_assignment(sexp)
      return unless sexp.is_a?(Array)
      event = sexp[0]

      return sexp.each { |s| traverse_sexp_in_assignment(s) } if event.is_a?(Array)
      if %i( @ident @cvar @ivar ).include?(event)
        return @lineno_to_variables[sexp[2][0]] << sexp[1]
      end

      traverse_sexp_in_assignment(sexp[1..sexp.length])
    end
  end
end
