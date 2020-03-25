# coding: utf-8

require 'test/unit'
require 'pry-inline'

class TestInline < Test::Unit::TestCase
  setup { PryInline::CodeExtension.send(:prepend, TerminalWidthExtension) }

  test 'assignment of local variable' do
    def greet
      message = 'Hello, world!'
      @binding = binding
      message
    end

    actual = output_of_whereami { greet }
    expected = <<EOF.chomp
def greet
  message = 'Hello, world!' # message: "Hello, world!"
  @binding = binding
  message
end
EOF
    assert { actual.end_with?(expected) }
  end

  test 'multiple assignment of local variables' do
    def multiple_assign
      x, y = 10, 20
      @binding = binding
    end

    actual = output_of_whereami { multiple_assign }
    expected = <<EOF.chomp
def multiple_assign
  x, y = 10, 20 # x: 10, y: 20
  @binding = binding
end
EOF
    assert { actual.end_with?(expected) }
  end

  test 'operator assign of local variables' do
    def opassign
      x, y, z = 1, 2, false
      x += 10
      y *= 10
      z ||= true
      @binding = binding
    end

    actual = output_of_whereami { opassign }
    expected = <<EOF.chomp
def opassign
  x, y, z = 1, 2, false
  x += 10 # x: 11
  y *= 10 # y: 20
  z ||= true # z: true
  @binding = binding
end
EOF
    assert { actual.end_with?(expected) }
  end

  test 'parameters of block' do
    def block_parameters
      (1..10).each do |i|
        @binding = binding if i == 5
      end
    end

    actual = output_of_whereami { block_parameters }
    expected = <<EOF.chomp
def block_parameters
  (1..10).each do |i| # i: 5
    @binding = binding if i == 5
  end
end
EOF
    assert { actual.end_with?(expected) }
  end

  test 'assignment of instance variable' do
    def assign_instance_variable
      @x = [1, 2, 3]
      @binding = binding
      @y = [4, 5, 6]
    end

    actual = output_of_whereami { assign_instance_variable }
    expected = <<EOF.chomp
def assign_instance_variable
  @x = [1, 2, 3] # @x: [1, 2, 3]
  @binding = binding
  @y = [4, 5, 6]
end
EOF
    assert { actual.end_with?(expected) }
  end

  test 'assignment of class variable' do
    def assign_class_variable
      @@var = { x: 10 }
      @binding = binding
    end

    actual = output_of_whereami { assign_class_variable }
    expected = <<EOF.chomp
def assign_class_variable
  @@var = { x: 10 } # @@var: {:x=>10}
  @binding = binding
end
EOF
    assert { actual.end_with?(expected) }
  end

  test 'assignment of global variable' do
    def assign_class_variable
      $var = { x: 10 }
      @binding = binding
    end

    actual = output_of_whereami { assign_class_variable }
    expected = <<EOF.chomp
def assign_class_variable
  $var = { x: 10 } # $var: {:x=>10}
  @binding = binding
end
EOF
    assert { actual.end_with?(expected) }
  end

  test 'assignment of var args' do
    def use_var_args(*args)
      @binding = binding
    end

    actual = output_of_whereami { use_var_args(1, 2, 3) }
    expected = <<EOF.chomp
def use_var_args(*args) # args: [1, 2, 3]
  @binding = binding
end
EOF
    assert { actual.end_with?(expected) }
  end

  test 'assignment after binding.pry' do
    def assignment_after_binding
      x = 10
      @binding = binding
      y = 10
    end

    actual = output_of_whereami { assignment_after_binding }
    expected = <<EOF.chomp
def assignment_after_binding
  x = 10 # x: 10
  @binding = binding
  y = 10
end
EOF
    assert { actual.end_with?(expected) }
  end

  test 'keyword arguments' do
    def keyword_arguments(a: 10, b: 20)
      @binding = binding
    end

    actual = output_of_whereami { keyword_arguments(b: 100) }
    expected = <<EOF.chomp
def keyword_arguments(a: 10, b: 20) # a: 10, b: 100
  @binding = binding
end
EOF
    assert { actual.end_with?(expected) }
  end

  test 'combinations of arguments' do
    def f(a, m = 1, *rest, x, k: 1, **kwrest)
      @binding = binding
    end
    expected = <<-EOF.split("\n").map(&:lstrip)
    def f(a, m = 1, *rest, x, k: 1, **kwrest) # a: "a", m: 2, rest: ["f", "b"], x: "x", k: 42, kwrest: {:u=>"u"}
      @binding = binding
    end
    EOF
    actual = output_of_whereami { f('a', 2, 'f', 'b', 'x', k: 42, u: 'u') }
    expected = <<EOF.chomp
def f(a, m = 1, *rest, x, k: 1, **kwrest) # a: "a", m: 2, rest: ["f", "b"], x: "x", k: 42, kwrest: {:u=>"u"}
  @binding = binding
end
EOF
    assert { actual.end_with?(expected) }
  end

  test 'too long function' do
    # FIXME: use `Pry::Command::Whereami.method_size_cutoff and Pry::Command#window_size`
    def too_long_function
      i = 0
      i += 1
      i += 1
      i += 1
      @binding = binding
      return i if i > 0
      i += 1
      i += 1
      i += 1
      i += 1
      i += 1
      i += 1
      i += 1
      i += 1
      i += 1
      i += 1
      i += 1
      i += 1
      i += 1
      i += 1
      i += 1
      i += 1
      i += 1
      i += 1
      i += 1
      i += 1
      i += 1
      i += 1
      i += 1
    end
    actual = output_of_whereami { too_long_function }
    expected = <<EOF.chomp
    def too_long_function
      i = 0
      i += 1
      i += 1
      i += 1 # i: 3
      @binding = binding
      return i if i > 0
      i += 1
      i += 1
      i += 1
      i += 1
EOF
    assert { actual.end_with?(expected) }
  end

  test 'line number' do
    def greet_with_line_number
      message = 'Hello, world!'
      @binding = binding
      message
    end

    actual = output_of_whereami(with_line_number: true) { greet_with_line_number }
    lineno = method(:greet_with_line_number).source_location[1]
    expected = <<EOF.chomp
    #{lineno + 0}: def greet_with_line_number
    #{lineno + 1}:   message = 'Hello, world!' # message: "Hello, world!"
 => #{lineno + 2}:   @binding = binding
    #{lineno + 3}:   message
    #{lineno + 4}: end
EOF
    assert { actual.end_with?(expected) }
  end

  test 'too long debug info' do
    def too_long_debug_info
      message = '0' * 100
      @binding = binding
    end

    actual = output_of_whereami(terminal_width: 40) { too_long_debug_info }
    #                                   <= 40
    expected = <<EOF.chomp
def too_long_debug_info
  message = '0' * 100 # message: "000000
  @binding = binding
end
EOF
    assert { actual.end_with?(expected) }
  end

  test 'too long debug info and line number' do
    def too_long_debug_info_and_line_number
      message = '0' * 100
      @binding = binding
    end

    actual = output_of_whereami(terminal_width: 40, with_line_number: true) do
      too_long_debug_info_and_line_number
    end
    lineno = method(:too_long_debug_info_and_line_number).source_location[1]
    expected = <<EOF.chomp
    #{lineno + 0}: def too_long_debug_info_and_line_number
    #{lineno + 1}:   message = '0' * 100 # message
 => #{lineno + 2}:   @binding = binding
    #{lineno + 3}: end
EOF
    assert { actual.end_with?(expected) }
  end

  test 'too long debug info including wide characters' do
    def too_long_debug_info_including_wide_characters
      a = 'あa' * 100
      @binding = binding
    end

    actual = output_of_whereami(terminal_width: 40) do
      too_long_debug_info_including_wide_characters
    end
    #                                   <= 40
    expected = <<EOF.chomp
def too_long_debug_info_including_wide_characters
  a = 'あa' * 100 # a: "あaあaあaあaあa
  @binding = binding
end
EOF
    assert { actual.end_with?(expected) }
  end

  test 'too long debug info including ambigous characters' do
    def too_long_debug_info_including_wide_characters
      a = 'あa☆' * 100
      @binding = binding
    end

    actual = output_of_whereami(terminal_width: 41) do
      too_long_debug_info_including_wide_characters
    end
    #                                    <= 41
    expected = <<EOF.chomp
def too_long_debug_info_including_wide_characters
  a = 'あa☆' * 100 # a: "あa☆あa☆あa☆
  @binding = binding
end
EOF
    assert { actual.end_with?(expected) }
  end

  test 'min debug info width option' do
    def min_debug_info
      message = '0' * 100
      @binding = binding
    end

    actual = output_of_whereami(terminal_width: 40, min_debug_info_width: 22) do
      min_debug_info
    end
    #                                   <= 40
    expected = <<EOF.chomp
def min_debug_info
  message = '0' * 100 # message: "0000000000000000000000000000000000000000000000
  @binding = binding
end
EOF
    assert { actual.end_with?(expected) }
  end

  test 'first statement' do
    # Note: Without `return x if x > 0` line,
    #       we'll see `x += 9 # x: 36` as a result of output_of_whereami method.
    #       Because output_of_whereami method makes output string
    #       after `foo` method finished (x becomes 36 by `x *= 3`).
    def foo(x)
      x += 9
      @binding = binding
      return x if x > 0
      x *= 3
      x
    end

    actual = output_of_whereami { foo(3) }
    expected = <<EOF.chomp
def foo(x)
  x += 9 # x: 12
  @binding = binding
  return x if x > 0
  x *= 3
  x
end
EOF
    assert { actual.end_with?(expected) }
  end

  test 'rescue variable' do
    def cause_error
      raise 'Hello, world!'
    rescue => e
      @binding = binding
    end

    actual = output_of_whereami { cause_error }
    expected = <<EOF.chomp
def cause_error
  raise 'Hello, world!'
rescue => e # e: #<RuntimeError: Hello, world!>
  @binding = binding
end
EOF
    assert { actual.end_with?(expected) }
  end

  private

  def output_of_whereami(terminal_width: 999,
                         min_debug_info_width: 0,
                         with_line_number: false,
                         &block)
    Pry.config.inline = { min_debug_info_width: min_debug_info_width }
    TerminalWidthExtension.terminal_width = terminal_width
    block.call
    output = StringIO.new

    args = {
      input: StringIO.new("whereami #{with_line_number ? '' : '-n'}\nexit"),
      output: output,
      color: false,
      pager: false,
      quiet: true
    }
    if Pry.respond_to?(:start_without_pry_byebug)
      Pry.start_without_pry_byebug(@binding, **args)
    else
      Pry.start(@binding, **args)
    end

    output.string.split("\n").slice(3..-1).join("\n")
  end
end
