module PryInline
  # monkey patch for Pry::Code
  module CodeExtension
    MAX_DEBUG_INFO_LENGTH = 80

    @@binding = nil

    def self.binding=(value)
      @@binding = value
    end

    def print_to_output(output, color = false)
      begin
        @lineno_to_variables = Hash.new { |h, k| h[k] = Set.new }
        traverse_sexp(Ripper.sexp(@lines.map(&:line).join("\n")))
        @lineno_to_variables.each do |lineno, variables|
          next if lineno == 0 || @lines.length <= lineno
          next if @with_marker && lineno > (@marker_lineno - @lines[0].lineno)
          add_debug_info(@lines[lineno - 1], variables)
        end
      ensure
        ret = super(output, color)
      end
      ret
    end

    private

    def traverse_sexp(sexp)
      return unless sexp.is_a?(Array)
      event = sexp[0]

      return sexp.each { |s| traverse_sexp(s) } if event.is_a?(Array)
      return traverse_sexp_in_assignment(sexp[1]) if %i( assign massign ).include?(event)
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

    def add_debug_info(loc, variables)
      return if !variables || (variables & defined_variables).size <= 0
      info = debug_info(variables)
      loc.tuple[0] += " # #{info[0..MAX_DEBUG_INFO_LENGTH]}"
      loc.tuple[0] += ' ...' if info.length > MAX_DEBUG_INFO_LENGTH
    end

    def defined_variables
      return [] unless @@binding
      @@binding.eval('local_variables').map(&:to_s) |
        @@binding.eval('self.instance_variables').map(&:to_s) |
        @@binding.eval('self.class.class_variables').map(&:to_s)
    end

    def debug_info(variables)
      variables.select { |k| defined_variables.include?(k) }
        .map { |k| "#{k}: #{@@binding.eval(k).inspect}" }
        .join(', ')
    end
  end
end
