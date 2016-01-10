require 'unicode'

module PryInline
  # monkey patch for Pry::Code
  module CodeExtension
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

        current_line = CodeExtension.current_binding.eval('__LINE__') - @lines[0].lineno + 1
        @lineno_to_variables.each do |lineno, variables|
          if lineno >= current_line
            variables.clear
            next
          end
          variables.each do |v|
            next unless @lineno_to_variables.any? do |l, vs|
              l < current_line && l > lineno && vs.include?(v)
            end
            variables.delete(v)
          end
        end

        @lineno_to_variables.each do |lineno, variables|
          next if lineno == 0 || @lines.length <= lineno

          original_width = Unicode.width(not_colorized_output_lines[lineno - 1], true)
          debug_info_width = terminal_width - original_width % terminal_width + 1
          debug_info_width += terminal_width if debug_info_width < min_debug_info_width

          @lines[lineno - 1].tuple[0] +=
            debug_info(variables)
            .slice(0, debug_info_width)
            .split('')
            .map { |c| [c, Unicode.width(c, true)] }
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
      if %i( @ident @cvar @ivar @gvar ).include?(event)
        return @lineno_to_variables[sexp[2][0]] << sexp[1]
      elsif %i( @label ).include?(event)
        return @lineno_to_variables[sexp[2][0]] << sexp[1].slice(0..-2)
      end

      traverse_sexp_in_assignment(sexp[1..-1])
    end

    def defined_variables
      return [] unless CodeExtension.current_binding
      %w(local_variables global_variables
         self.instance_variables self.class.class_variables).map do |exp|
        CodeExtension.current_binding.eval(exp)
      end.flatten.to_set.map(&:to_s)
    end

    def debug_info(variables)
      return '' if !variables || (variables & defined_variables).size <= 0
      ' # ' + variables.select { |k| defined_variables.include?(k) }
        .map { |k| "#{k}: #{CodeExtension.current_binding.eval(k).inspect.delete("\n")}" }
        .join(', ')
    end

    def min_debug_info_width
      if Pry.config.inline.is_a?(Hash)
        min_width = Pry.config.inline[:min_debug_info_width]
      end
      min_width || 16
    end
  end
end
