  using Plots
  using DataFrames
  using CSV
  using Dates

  function readDeltaresData(aDay :: Int64, aProfile :: Int64, aPosition :: Int64)
    dataRead = nothing
    try
      try
        baseFileName = "/home/wesseling/DataDisk/Wesseling/Work/Warmteleiding/DataDeltares/"
        dataFile = "profiel" * string(aProfile) * "/sim_" * string(aDay+364) * "c" * string(aPosition) * ".csv"
        dataFile = baseFileName * dataFile
        dataRead = CSV.read(dataFile, DataFrame)
#        dataRead[:,"Temperature"] = dataRead[:,"Temperature"] .- 273.15
        dataRead[:,"Head"] = (dataRead[:,"Head"] .- dataRead[:, "Y"]) .* 100.0
      catch e
        println("???ERROR in readDeltaresData: ", e)
      end
    finally
    end
    return dataRead
  end

  profiles = [16,21,31,57]

  for profile in 1:size(profiles,1)
    myProfile = profiles[profile]
    temp1c1 = Array{Float64}(undef,366)
    temp2c1 = Array{Float64}(undef,366)
    temp1c4 = Array{Float64}(undef,366)
    temp2c4 = Array{Float64}(undef,366)
    head1c1 = Array{Float64}(undef,366)
    head2c1 = Array{Float64}(undef,366)
    head1c4 = Array{Float64}(undef,366)
    head2c4 = Array{Float64}(undef,366)
    myDate = Array{Date}(undef,366)
    d = Date(2019,12,31)
    for i in 1:366
      d += Dates.Day(1)
      myDate[i] = d
    end

    position = 1
    for i in 1:366
      df = readDeltaresData(i, myProfile, position)
      temp1c1[i] = df[2,"Temperature"]
      temp2c1[i] = df[9,"Temperature"]
      head1c1[i] = df[2,"Head"]
      head2c1[i] = df[9,"Head"]
    end

    position = 4
    for i in 1:366
      df = readDeltaresData(i, myProfile, position)
      temp1c4[i] = df[2,"Temperature"]
      temp2c4[i] = df[9,"Temperature"]
      head1c4[i] = df[2,"Head"]
      head2c4[i] = df[9,"Head"]
    end

    p = Plots.Plot{Plots.GRBackend}[]
    resize!(p,4)

    lim = [0.0, 30.0]
    p[1] = plot(legend=:none, title="T at 5 cm (C)", xlabel="T at location 1", ylabel="T at location 4", size=(500,500))
    p[1] = plot!(p[1], temp1c1, temp1c4, label = "T", color=:darkred, markerstrokewidth=0, seriestype=:scatter, markershape=:circle, markersize=4)
    p[1] = plot!(p[1], lim, lim, label="1:1", linestyle=:dash, color=:blue)

    p[2] = plot(legend=:none, title="T at 40 cm (C)", xlabel="T at location 1", ylabel="T at location 4", size=(500,500))
    p[2] = plot!(p[2], temp2c1, temp2c4, label = "T", color=:darkred, markerstrokewidth=0,  seriestype=:scatter, markershape=:circle, markersize=4)
    p[2] = plot!(p[2], lim, lim, label="1:1", linestyle=:dash, color=:blue)

    lim = [-850.0, 0.0]
    p[3] = plot(legend=:none, title="h at 5 cm (cm)", xlabel="h at location 1", ylabel="h at location 4", size=(500,500))
    p[3] = plot!(p[3], head1c1, head1c4, label = "h", color=:darkred, markerstrokewidth=0,  seriestype=:scatter, markershape=:circle, markersize=4)
    p[3] = plot!(p[3], lim, lim, label="1:1", linestyle=:dash, color=:blue)

    lim = [-100.0, 30.0]
    p[4] = plot(legend=:none, title="h at 40 cm", xlabel="h at location 1", ylabel="h at location 4", size=(500,500))
    p[4] = plot!(p[4], head2c1, head2c4, label = "h", color=:darkred, markerstrokewidth=0,  seriestype=:scatter, markershape=:circle, markersize=4)
    p[4] = plot!(p[4], lim, lim, label="1:1", linestyle=:dash, color=:blue)

    pAll = plot(p..., layout=(2,2), size=(1000,1000))
#  display(pAll)
    savefig("/home/wesseling/DataDisk/Wesseling/Work/Warmteleiding/Output/xys_" * string(myProfile) * ".svg")

    p[1] = plot(legend=:none, title="T c1-c4 (C) at 5 cm", xlabel="Date", ylabel="T (C)", size=(500,500))
    p[1] = plot!(p[1], myDate, temp1c1 - temp1c4, linestyle=:solid, color=:darkred)

    p[2] = plot(legend=:none, title="T c1-c4 (C) at 40 cm", xlabel="Date", ylabel="T (C)", size=(500,500))
    p[2] = plot!(p[2], myDate, temp2c1 - temp2c4, linestyle=:solid, color=:darkred)

    p[3] = plot(legend=:none, title="h c1-c4 (C) at 5 cm", xlabel="Date", ylabel="h (cm)", size=(500,500))
    p[3] = plot!(p[3], myDate, head1c1 - head1c4, linestyle=:solid, color=:darkred)

    p[4] = plot(legend=:none, title="h c1-c4 (C) at 40 cm", xlabel="Date", ylabel="h (cm)", size=(500,500))
    p[4] = plot!(p[4], myDate, head2c1 - head2c4, linestyle=:solid, color=:darkred)

    pAll = plot(p..., layout=(2,2), size=(1000,1000))
    display(pAll)
    savefig("/home/wesseling/DataDisk/Wesseling/Work/Warmteleiding/Output/differences_" * string(myProfile) * ".svg")
  end
