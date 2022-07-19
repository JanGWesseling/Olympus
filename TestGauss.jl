Gauss3x = [0.1127017, 0.5000000, 0.8872983]
Gauss3w = [0.2777778, 0.4444444, 0.2777778]

  function f(x :: Float64)
    y = 3.0 * x * x
    return y
  end
  
x1 = 3.0
x2 = 10.0
a=0.0
for i in 1:3
       x= x1 + (x2 - x1) * Gauss3x[i]
       global a+= Gauss3w[i]* f(x)
end
a*=(x2-x1)

       println(a)
