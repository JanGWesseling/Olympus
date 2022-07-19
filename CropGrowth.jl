  using Dates
  include("Control.jl")

  df = DateFormat("dd-u-yyyy HH:MM:SS")
  println("Program started at " * Dates.format(Dates.now(), df))

  year = 2020
#  Control.readMeteo(year)
#  Control.plotMeteoData(year)
#  Control.computePenman(year)
  Control.simulateGrowth(year)

  println("Program ended at " * Dates.format(Dates.now(), df))
