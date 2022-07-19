  using Dates
  include("Types.jl")
  include("Control.jl")

  df = DateFormat("dd-u-yyyy HH:MM:SS.sss")
  println("Program started at " * Dates.format(Dates.now(), df))

  Control.process()

  println("Program ended at " * Dates.format(Dates.now(), df))
