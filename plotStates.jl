  using Plots
  using Dates
  using DataFrames
  using MySQL

  function readTemperatures(aNode :: Int64)
   df = DataFrame()
    myConnection = DBInterface.connect(MySQL.Connection, "127.0.0.1", "olympus", "Olympus.01", db="olympus")
    try
      try
        sqlSelect = "SELECT time,temperature FROM states WHERE nodeid=" * string(aNode) * " ORDER BY time;"
        res = DBInterface.execute(myConnection, sqlSelect)
        df = DataFrame(res)
      catch e
        println("????Error in readTemperatures: ",e)
      end
    finally
      DBInterface.close!(myConnection)
    end
    return df
  end

  df = DataFrame()
  label = ["0.0 m",  "0.1 m", "0.2 m", "0.5 m", "0.7 m", "1.0 m",]
  myColor = [:black,    :red,    :blue,  :green, :orange,  :lime]

  p1 = plot(legend=true, title="Temperatures at -0.25 m", xlabel="Date", ylabel="Temperature (C)", size=(500,500))
  node  = [      519,    533,    539,    545,    549,      555]
  n = size(node,1)
  df = readTemperatures(node[1])
  x = Array{DateTime}(undef, size(df,1))
  y = Array{Float64}(undef, size(df,1))

  t0 = Array{Float64}(undef, size(df,1))
  x[:] = df[:,1]
  t0[:] = df[:,2]

  for i in 2:n
    global df = readTemperatures(node[i])


    y[:] = t0[:] - df[:,2]

    global p1=plot!(p1,x,y,color=myColor[i],label=label[i])
  end

  p2 = plot(legend=true, title="Temperatures at -0.5 m", xlabel="Date", ylabel="Temperature (C)", size=(500,500))
  node  = [      889,    903,    909,   915,      919,    925]
  n = size(node,1)
  for i in 1:n
    global df = readTemperatures(node[i])

    resize!(x, size(df,1))
    resize!(y, size(df,1))
#    x = Array{DateTime}(undef, size(df,1))
#    y = Array{Float64}(undef, size(df,1))

    x[:] = df[:,1]
    y[:] = df[:,2]

    global p2=plot!(p2,x,y,color=myColor[i],label=label[i])
  end

  p3 = plot(legend=true, title="Temperatures at -1 m", xlabel="Date", ylabel="Temperature (C)", size=(500,500))
  node  = [     1259,   1273,   1279,  1285,     1289,   1295]
  n = size(node,1)
  for i in 1:n
    global df = readTemperatures(node[i])

    resize!(x, size(df,1))
    resize!(y, size(df,1))
#    x = Array{DateTime}(undef, size(df,1))
#    y = Array{Float64}(undef, size(df,1))

    x[:] = df[:,1]
    y[:] = df[:,2]

    global p3=plot!(p3,x,y,color=myColor[i],label=label[i])
  end

  p4 = plot(legend=true, title="Temperatures at -1.5 m", xlabel="Date", ylabel="Temperature (C)", size=(500,500))
  node  = [     2221,    2235,   2241,  2247,    2251,  2257]
  n = size(node,1)
  for i in 1:n
    global df = readTemperatures(node[i])

    resize!(x, size(df,1))
    resize!(y, size(df,1))
#    x = Array{DateTime}(undef, size(df,1))
#    y = Array{Float64}(undef, size(df,1))

    x[:] = df[:,1]
    y[:] = df[:,2]

    global p4=plot!(p4,x,y,color=myColor[i],label=label[i])
  end

  p = plot(p1,p2,p3,p4,layout=(2,2),size=(1000,1000))

  savefig("/home/wesseling/DataDisk/Wesseling/WesW/3d/Output/temperatures.svg")

  display(p)

  exit(0)
