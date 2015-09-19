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
    assert_equal <<EOF.chomp, actual
def greet
  message = 'Hello, world!' # message: "Hello, world!"
  @binding = binding
  message
end
EOF
  end

  test 'multiple assignment of local variables' do
    def multiple_assign
      x, y = 10, 20
      @binding = binding
    end

    actual = output_of_whereami { multiple_assign }
    assert_equal <<EOF.chomp, actual
def multiple_assign
  x, y = 10, 20 # x: 10, y: 20
  @binding = binding
end
EOF
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
    assert_equal <<EOF.chomp, actual
def opassign
  x, y, z = 1, 2, false
  x += 10 # x: 11
  y *= 10 # y: 20
  z ||= true # z: true
  @binding = binding
end
EOF
  end

  test 'parameters of block' do
    def block_parameters
      (1..10).each do |i|
        @binding = binding if i == 5
      end
    end

    actual = output_of_whereami { block_parameters }
    assert_equal <<EOF.chomp, actual
def block_parameters
  (1..10).each do |i| # i: 5
    @binding = binding if i == 5
  end
end
EOF
  end

  test 'assignment of instance variable' do
    def assign_instance_variable
      @x = [1, 2, 3]
      @binding = binding
      @y = [4, 5, 6]
    end

    actual = output_of_whereami { assign_instance_variable }
    assert_equal <<EOF.chomp, actual
def assign_instance_variable
  @x = [1, 2, 3] # @x: [1, 2, 3]
  @binding = binding
  @y = [4, 5, 6]
end
EOF
  end

  test 'assignment of class variable' do
    def assign_class_variable
      @@var = { x: 10 }
      @binding = binding
    end

    actual = output_of_whereami { assign_class_variable }
    assert_equal <<EOF.chomp, actual
def assign_class_variable
  @@var = { x: 10 } # @@var: {:x=>10}
  @binding = binding
end
EOF
  end

  test 'assignment of global variable' do
    def assign_class_variable
      $var = { x: 10 }
      @binding = binding
    end

    actual = output_of_whereami { assign_class_variable }
    assert_equal <<EOF.chomp, actual
def assign_class_variable
  $var = { x: 10 } # $var: {:x=>10}
  @binding = binding
end
EOF
  end

  test 'assignment of var args' do
    def use_var_args(*args)
      @binding = binding
    end

    actual = output_of_whereami { use_var_args(1, 2, 3) }
    assert_equal <<EOF.chomp, actual
def use_var_args(*args) # args: [1, 2, 3]
  @binding = binding
end
EOF
  end

  test 'assignment after binding.pry' do
    def assignment_after_binding
      x = 10
      @binding = binding
      y = 10
    end

    actual = output_of_whereami { assignment_after_binding }
    assert_equal <<EOF.chomp, actual
def assignment_after_binding
  x = 10 # x: 10
  @binding = binding
  y = 10
end
EOF
  end

  test 'keyword arguments' do
    def keyword_arguments(a: 10, b: 20)
      @binding = binding
    end

    actual = output_of_whereami { keyword_arguments(b: 100) }
    assert_equal <<EOF.chomp, actual
def keyword_arguments(a: 10, b: 20) # a: 10, b: 100
  @binding = binding
end
EOF
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
    assert_equal <<EOF.chomp, actual
def f(a, m = 1, *rest, x, k: 1, **kwrest) # a: "a", m: 2, rest: ["f", "b"], x: "x", k: 42, kwrest: {:u=>"u"}
  @binding = binding
end
EOF
  end

  test 'too long function' do
    # FIXME: use `Pry::Command::Whereami.method_size_cutoff and Pry::Command#window_size`
    def too_long_function
      i = 0
      i += 1
      i += 1
      i += 1
      @binding = binding
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
    assert_equal <<EOF.chomp, actual
    def too_long_function
      i = 0
      i += 1
      i += 1
      i += 1
      @binding = binding
      i += 1
      i += 1
      i += 1
      i += 1
      i += 1
EOF
  end

  private

  def output_of_whereami(terminal_width: 999,
                         with_line_number: false,
                         &block)
    TerminalWidthExtension.terminal_width = terminal_width
    block.call
    output = StringIO.new

    Pry.start(@binding,
              input: StringIO.new("whereami #{with_line_number ? '' : '-n'}\nexit"),
              output: output,
              color: false,
              pager: false,
              quiet: true)
    output.string.split("\n").slice(3..-1).join("\n")
  end
end
