  using Dates
  include("Control.jl")

  println("  ")
  df = DateFormat("dd-u-yyyy HH:MM:SS")
  println("Program started at " * Dates.format(Dates.now(), df))

  year = 2019
#  Control.readMeteo(year)
  Control.simulatePotatoGrowth(year)
#  Control.simulateGrassGrowth(year)

  println("Program ended at " * Dates.format(Dates.now(), df))
