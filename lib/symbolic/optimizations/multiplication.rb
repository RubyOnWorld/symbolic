module Symbolic::Optimization::Multiplication
  extend Symbolic::Optimization::Base

  def self.optimize_first_arg(var1, var2)
    if var1 == 0
      0
    elsif var1 == 1
      var2
    elsif negative?(var1)
      -(var1.abs * var2)
    end
  end

  def self.optimize_second_arg(var1, var2)
    if var2.is_a? Numeric
      var2 * var1
    else
      optimize_first_arg var2, var1
    end
  end
end