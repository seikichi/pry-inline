module PryInline
  # monkey patch for Pry::Code::LOC
  module InlineDebuggableLOC
    MAX_DEBUG_INFO_LENGTH = 80

    @@binding = nil

    attr_accessor :variables

    def dup
      super.tap { |ret| ret.variables = variables }
    end

    def colorize(code_type)
      if @variables && (@variables & defined_variables).size > 0
        if debug_info.length <= MAX_DEBUG_INFO_LENGTH
          tuple[0] += " # #{debug_info}"
        else
          tuple[0] += " # #{debug_info[0..MAX_DEBUG_INFO_LENGTH]} ...}"
        end
      end
    ensure
      super(code_type)
    end

    def self.binding=(value)
      @@binding = value
    end

    private

    def defined_variables
      return [] unless @@binding
      @@binding.eval('local_variables').map(&:to_s) |
        @@binding.eval('self.instance_variables').map(&:to_s) |
        @@binding.eval('self.class.class_variables').map(&:to_s)
    end

    def debug_info
      @variables.select { |k| defined_variables.include?(k) }
        .map { |k| "#{k}: #{@@binding.eval(k).inspect}" }
        .join(', ')
    end
  end
end
