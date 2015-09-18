require 'unicode'

module PryInline
  # monkey patch for Pry::Code
  module CodeExtension
    MIN_DEBUG_INFO_LENGTH = 8

    def self.current_binding
      @current_binding
    end

    def self.current_binding=(value)
      @current_binding = value
    end

    def print_to_output(output, color = false)
      begin
        not_colorized_output_lines = super('', false).split("\n")
        @lineno_to_variables = Hash.new { |h, k| h[k] = Set.new }
        traverse_sexp(Parser.sexp(@lines.map(&:line).join("\n")))
        @lineno_to_variables.each do |lineno, variables|
          next if lineno == 0 || @lines.length <= lineno
          next if @with_marker && lineno > (@marker_lineno - @lines[0].lineno)

          original_width = Unicode.width(not_colorized_output_lines[lineno - 1])
          debug_info_width = terminal_width - original_width % terminal_width
          debug_info_width += terminal_width if debug_info_width < MIN_DEBUG_INFO_LENGTH

          @lines[lineno - 1].tuple[0] +=
            debug_info(variables)
            .slice(0, debug_info_width)
            .split('')
            .map { |c| [c, Unicode.width(c)] }
            .reduce([]) { |a, e| a + [[e[0], e[1] + (a.empty? ? 0 : a[-1][1])]] }
            .take_while { |_, w| w < debug_info_width }
            .map(&:first)
            .join
        end
      ensure
        ret = super(output, color)
      end
      ret
    end

    private

    def terminal_width
      `tput cols`.to_i
    end

    def traverse_sexp(sexp)
      return unless sexp.is_a?(Array)
      event = sexp[0]

      return sexp.each { |s| traverse_sexp(s) } if event.is_a?(Array)
      return traverse_sexp_in_assignment(sexp[1]) if %i( assign opassign massign ).include?(event)
      return traverse_sexp_in_assignment(sexp[1..-1]) if event == :params
      traverse_sexp(sexp[1..-1]) unless event.to_s.start_with?('@')
    end

    def traverse_sexp_in_assignment(sexp)
      return unless sexp.is_a?(Array)
      event = sexp[0]

      return sexp.each { |s| traverse_sexp_in_assignment(s) } if event.is_a?(Array)
      if %i( @ident @cvar @ivar ).include?(event)
        return @lineno_to_variables[sexp[2][0]] << sexp[1]
      elsif %i( @label ).include?(event)
        return @lineno_to_variables[sexp[2][0]] << sexp[1].slice(0..-2)
      end

      traverse_sexp_in_assignment(sexp[1..-1])
    end

    def defined_variables
      return [] unless CodeExtension.current_binding
      CodeExtension.current_binding.eval('local_variables').map(&:to_s) |
        CodeExtension.current_binding.eval('self.instance_variables').map(&:to_s) |
        CodeExtension.current_binding.eval('self.class.class_variables').map(&:to_s)
    end

    def debug_info(variables)
      return '' if !variables || (variables & defined_variables).size <= 0
      ' # ' + variables.select { |k| defined_variables.include?(k) }
        .map { |k| "#{k}: #{CodeExtension.current_binding.eval(k).inspect.delete("\n")}" }
        .join(', ')
    end
  end
end
