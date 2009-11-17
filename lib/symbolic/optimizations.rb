module Symbolic
  module Optimizations
    def self.plus(symbolic_var, var, reverse=false)
      if var == 0
        symbolic_var
      elsif var.is_a? UnaryMinus
        symbolic_var - var.variable
      elsif reverse && symbolic_var.is_a?(UnaryMinus)
        var - symbolic_var.variable
      else
        if reverse
          Expression.new var, symbolic_var, '+'
        else
          Expression.new symbolic_var, var, '+'
        end
      end
    end

    def self.minus(symbolic_var, var, reverse=false)
      if var == 0
        symbolic_var
      elsif var.is_a? UnaryMinus
        symbolic_var + var.variable
      elsif reverse && symbolic_var.is_a?(UnaryMinus)
        var + symbolic_var.variable
      else
        if reverse
          Expression.new var, symbolic_var, '-'
        else
          Expression.new symbolic_var, var, '-'
        end
      end
    end

    def self.multiply(symbolic_var, var, reverse=false)
      if var == 0
        var
      elsif var == 1
        symbolic_var
      elsif var == -1
        -symbolic_var
      elsif var.is_a?(Numeric) && var < 0
        -(-var*symbolic_var)
      elsif var.is_a? UnaryMinus
        UnaryMinus.create symbolic_var*var.variable
      elsif symbolic_var.is_a? UnaryMinus
        UnaryMinus.create symbolic_var.variable*var
      else
        if reverse
          Expression.new var, symbolic_var, '*'
        else
          Expression.new symbolic_var, var, '*'
        end
      end
    end
  end
end