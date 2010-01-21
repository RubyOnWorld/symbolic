#!/usr/bin/env ruby -w
require File.expand_path(File.dirname(__FILE__) +'/spec_helper')

describe "Symbolic" do
  before(:all) do
    @x = var :x, 1
    @y = var :y, 2
  end

  def expression(string)
    eval string.gsub(/[xy]/, '@\0')
  end

  def self.should_equal(conditions)
    conditions.each do |non_optimized, optimized|
      it non_optimized do
        expression(non_optimized).should == expression(optimized)
      end
    end
  end

  def self.should_evaluate_to(conditions)
    conditions.each do |symbolic_expression, result|
      it symbolic_expression do
        expression(symbolic_expression).value.should == result
      end
    end
  end

  def self.should_print(conditions)
    conditions.each do |symbolic_expression, result|
      it symbolic_expression do
        expression(symbolic_expression).to_s.should == result
      end
    end
  end

  describe "evaluation (x=1, y=2):" do
    should_evaluate_to \
    'x'         => 1,
    'y'         => 2,
    '+x'        => 1,
    '-x'        => -1,
    'x + 4'     => 5,
    '3 + x'     => 4,
    'x + y'     => 3,
    'x - 1'     => 0,
    '1 - x'     => 0,
    'x - y'     => -1,
    '-x + 3'    => 2,
    '-y - x'    => -3,
    'x*3'       => 3,
    '4*y'       => 8,
    '(+x)*(-y)' => -2,
    'x/2'       => 0.5,
    'y/2'       => 1,
    '-2/x'      => -2,
    '4/(-y)'    => -2,
    'x**2'      => 1,
    '4**y'      => 16,
    'y**x'      => 2
  end

  describe "optimization:" do
    should_equal \
    '-(-x)'       => 'x',

    '0 + x'       => 'x',
    'x + 0'       => 'x',
    'x + (-2)'    => 'x - 2',
    '-2 + x'      => 'x - 2',
    '-x + 2'      => '2 - x',
    'x + (-y)'    => 'x - y',
    '-y + x'      => 'x - y',

    '0 - x'       => '-x',
    'x - 0'       => 'x',
    'x - (-2)'    => 'x + 2',
    '-2 - (-x)'   => 'x - 2',
    'x - (-y)'    => 'x + y',

    '0 * x'       => '0',
    'x * 0'       => '0',
    '1 * x'       => 'x',
    'x * 1'       => 'x',
    '-1 * x'      => '-x',
    'x * (-1)'    => '-x',
    'x * (-3)'    => '-(x*3)',
    '-3 * x'      => '-(x*3)',
    '-3 * (-x)'   => 'x*3',
    'x*(-y)'      => '-(x*y)',
    '-x*y'        => '-(x*y)',
    '(-x)*(-y)'   => 'x*y',

    '0 / x'       => '0',
    'x / 1'       => 'x',

    '0**x'        => '0',
    '1**x'        => '1',
    'x**0'        => '1',
    'x**1'        => 'x',
    '(-x)**1'     => '-x',
    '(-x)**2'     => 'x**2',
    '(x**2)**y'   => 'x**(2*y)',

    'x*4*x'       => '4*x**2',
    'x*(-1)*x**(-1)' => '-1',
    'x**2*(-1)*x**(-1)' => '-x',
    'x + y - x' => 'y',
    '2*x + x**1 - y**2/y - y' => '3*x - 2*y',
    '-(x+4)' => '-x-4',

    '(x/y)/(x/y)' => '1',
    '(y/x)/(x/y)' => 'y**2/x**2'
  end

  describe 'Variable methods:' do
    x, y = var(:x), var(:y)

    it 'expression variables' do
      x.variables.should == [x]

    end
    it 'expression variables' do
      (-(x+y)).variables.should == [x,y]
    end

    it 'operations' do
      (-x**y-4*y+5-y/x).operations.should == {:+ => 1, :- => 2, :* => 1, :/ => 1, :-@ => 1, :** => 1}
    end

    it 'proc value' do
      x = var :x, 2
      y = var { x**2 }
      x.value = 3
      (x*y).value.should == 27
    end

    it '(var without value).value = nil' do
      var.value.should == nil
    end

    it '(var without name).name == "unnamed_variable"' do
      (2*var).to_s.should == "2*unnamed_variable"
    end

    it 'math method' do
      cos = Symbolic::Math.cos(x)
      x.value = 0
      cos.value.should == 1.0
    end
  end

  describe "to_s:" do
    should_print \
    'x' => 'x',
    '-x' => '-x',
    'x+1' => 'x+1',
    'x-4' => 'x-4',
    '-x-4' => '-x-4',
    '-(x+y)' => '-x-y',
    '-(x-y)' => '-x+y',
    'x*y' => 'x*y',
    '(-x)*y' => '-x*y',
    '(x+2)*(y+3)*4' => '4*(x+2)*(y+3)',
    '4/x' => '4/x',
    '2*x**(-1)*y**(-1)' => '2/(x*y)',
    '(-(2+x))/(-(-y))' => '(-x-2)/y',
    'x**y' => 'x**y',
    'x**(y-4)' => 'x**(y-4)',
    '(x+1)**(y*2)' => '(x+1)**(2*y)',
    '-(x**y -2)+5' => '-x**y+7'
  end
end
