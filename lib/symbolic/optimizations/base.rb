module Symbolic::Optimizations::Base
  def optimize(var1, var2)
    optimize_first_arg(var1, var2) || optimize_second_arg(var1, var2)
  end

  def negative?(var)
    var.is_a?(Symbolic::UnaryMinus) || (var.is_a?(Numeric) && var < 0)
  end
end