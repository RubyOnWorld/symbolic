class Symbolic::Operation::Binary < Symbolic::Operation
  def self.simplify(var1, var2)
    simplify_first_arg(var1, var2) || simplify_second_arg(var1, var2)
  end

  def self.symmetric
    def self.simplify(var1, var2)
      simplify_first_arg(var1, var2) || simplify_first_arg(var2, var1)
    end

    def ==(object)
      (object.class == self.class) &&
      ((object.var1 == @var1 && object.var2 == @var2) || (object.var1 == @var2 && object.var2 == @var1))
    end
  end

  def initialize(var1, var2)
    @var1, @var2 = var1, var2
  end

  def variables
    @var1.variables | @var2.variables
  end

  def undefined_variables
    variables.select {|it| it.value.nil? }
  end

  def value
    @var1.value.send sign, @var2.value if undefined_variables.empty?
  end

  def to_s
    "#{@var1}#{sign}#{@var2}"
  end

  def ==(object)
    (object.class == self.class) && (object.var1 == @var1 && object.var2 == @var2)
  end

  protected

  attr_reader :var1, :var2
end