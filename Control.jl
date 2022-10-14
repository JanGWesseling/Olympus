module Control
  include("Types.jl")
  include("DataManager.jl")
  include("FEM.jl")
  include("Grass.jl")
  include("Potato.jl")
  include("Meteo.jl")
  using DataFrames
  using ConfParser
  using FileIO
  using Dates
  using Plots
  using GLM
  using Printf
  using CSV

  simulatedTemp = undef
  simulatedHead = undef

  status = 0
  year = 0
  scenario = Array{Types.Scenario}
  meteo = Array{Types.Meteo}

  potatoYield = Array{Float64}(undef,6,4)
  potatoDateEmergence = Array{String}(undef,6,4)
  potatoDateMature = Array{String}(undef,6,4)
  potatoTranspiration = Array{Float64}(undef,6,4)

  potatoMoisture = Array{Float64}(undef,6,4)
  potatoTemperature = Array{Float64}(undef,6,4)
  potatoPotential = Array{Float64}(undef,6,4)

  grassTranspiration = Array{String}(undef,6,4)
  grassFirstMowingDate = Array{String}(undef,6,4)
  grassHarvested = Array{String}(undef,6,4)
  grassLeftAtField = Array{String}(undef,6,4)

  baseDir = "/home/wesseling/DataDisk/Wesseling/Work/Waterstof/Output/"

  function readIniFile()
    result = 0
    xCoord = Array{Float64}(undef,1)
    yCoord = Array{Float64}(undef,1)
    zCoord = Array{Float64}(undef,1)

    fileName = "/home/wesseling/DataDisk/Wesseling/WesW/3d/Julia/Olympus.ini"
    if isfile(fileName)
      iniFile = ConfParse(fileName)
      parse_conf!(iniFile)

      nX = parse(Int64, retrieve(iniFile, "Grid", "nX"))
      resize!(xCoord,nX)
      for i in 1:nX
        name = "x" * string(i)
#        println(name)
        xCoord[i] = parse(Float64, retrieve(iniFile, "Grid", name))
      end
#      println(xCoord)

      nY = parse(Int64, retrieve(iniFile, "Grid", "nY"))
      resize!(yCoord,nY)
      for i in 1:nY
        name = "y" * string(i)
#        println(name)
        yCoord[i] = parse(Float64, retrieve(iniFile, "Grid", name))
      end
#      println(yCoord)

      nZ = parse(Int64, retrieve(iniFile, "Grid", "nZ"))
      resize!(zCoord,nZ)
      for i in 1:nZ
        name = "z" * string(i)
#        println(name)
         zCoord[i] = parse(Float64, retrieve(iniFile, "Grid", name))
      end
#      println(zCoord)

      FEM.setCoordinates(xCoord, yCoord, zCoord)
    else
      println("???ERROR: Inifile does not exist!")
      result = -1
    end
    return result
  end

  function readCoordinates(aFemId :: Int64)
    result = 0
    try
      try
        xCoord = DataManager.readPositions(aFemId,1)
        yCoord = DataManager.readPositions(aFemId,2)
        zCoord = DataManager.readPositions(aFemId,3)

        FEM.setCoordinates(xCoord, yCoord, zCoord)
      catch e
        println("???ERROR in readCoordinates: ", e)
        result = -1
      end
    finally
    end
    return result
  end

  function process()
    status = 0
#    println("Reading ini-file.....")
#    status = readIniFile()

#    if status == 0
    global scenario = DataManager.readScenarios()
#    end
#    println(scenario)
#    exit(0)

    for i in 1:size(scenario,1)
      if scenario[i].active
        runStatus = 0
        println("Deleting old states.....")
        DataManager.deleteStates(scenario[i].scenarioid)
        println("Preparing grid.....")
        if readCoordinates(scenario[i].femid) == 0
          runStatus = FEM.prepare(scenario[i].femid)
          if runStatus == 0
            println("Processing........")
            readMeteo(scenario[i].meteostation, Dates.year(scenario[i].startTime))
            runStatus = FEM.process(meteo, scenario[i].scenarioid, scenario[i].startTime, scenario[i].endTime, scenario[i].dtMax)
          end
        end
      end
    end
  end



  function readMeteo(aStation :: Int64, aYear :: Int64)
    global meteo = DataManager.readMeteo(aStation, aYear)
#    println(meteo[365])
  end

  function plotEvaporation(aYear :: Int64)
    try
      try
        nDays = size(meteo,1)
        makking = Array{Float64}(undef,nDays)
        penman = Array{Float64}(undef,nDays)
        makkingCum = Array{Float64}(undef,nDays)
        penmanCum = Array{Float64}(undef,nDays)
        date = Array{DateTime}(undef,nDays)

        date[1] = meteo[1].date
        penman[1] = meteo[1].evapPenman
        makking[1] = meteo[1].evapMakking
        penmanCum[1] = meteo[1].evapPenman
        makkingCum[1] = meteo[1].evapMakking
        for i in 2:nDays
          date[i] = meteo[i].date
          penman[i] = meteo[i].evapPenman
          makking[i] = meteo[i].evapMakking
          penmanCum[i] = penmanCum[i-1] + meteo[i].evapPenman
          makkingCum[i] = makkingCum[i-1] + meteo[i].evapMakking
        end

        p1 = plot(legend=true, xlabel="Date", ylabel="Evapotranspiration (mm/day)",size=(500,500))
        p2 = plot(legend=true, xlabel="Date", ylabel="Evapotranspiration (mm)", size=(500,500))
        p1 = plot!(p1,date,makking,label="Makking",color=:blue)
        p1 = plot!(p1,date,penman,label="Penman",color=:red)
        p2 = plot!(p2,date,makkingCum,label="Makking",color=:blue)
        p2 = plot!(p2,date,penmanCum,label="Penman",color=:red)
        p3=plot(p1,p2,layout=(2,1))
        display(p3)
#        savefig("/home/wesseling/DataDisk/Wesseling/WesW/3d/Output/evaporationData_" * string(aYear) * ".png")

        p4 = plot(legend=false, xlabel="Penman", ylabel="Makking",size=(500,500), xlims=(0.0,7.0), ylims=(0.0,7.0))
        x = [0.0, 7.0]
        y = [0.0, 7.0]
        p4 = plot!(p4, x, y, color=:black, seriestype=:path, linestyle=:dot)
        p4 = plot!(p4, penman, makking, seriestype=:scatter, markershape=:diamond, markersize=7)

        df = DataFrame()
        df.x = penman
        df.y = makking

        lr = lm(@formula(y ~ x), df)
#        println(lr)
        slope = GLM.coeftable(lr).cols[1][2]
        intercept = GLM.coeftable(lr).cols[1][1]
#        println(intercept)

        x[1] = 0.0
        y[1] = intercept
        x[2]=7.0
        y[2] = intercept + slope * x[2]
        p4 = plot!(p4, x, y, seriestype=:path, color=:blue, linestyle=:dash)
        myText = "Makking =" * @sprintf("%5.2f",intercept) * " +" * @sprintf("%6.3f", slope) * " * Penman"
        p4 = annotate!(p4, x[2], y[2], text(myText, :blue, :right, 10))
#        display(p4)
#        savefig("/home/wesseling/DataDisk/Wesseling/WesW/3d/Output/evaporationXY_" * string(aYear) * ".png")
      catch ex
        println("???ERROR in plotEvaporation: ",ex)
      end
    finally
    end
  end

  function computePenman(aYear :: Int64)
    try
      try
        global year = aYear
        station = 344
        readMeteo(station, year)
        tPrevious = 0.0
        for i in 1:size(meteo,1)
          if i > 3
            tPrevious = (meteo[i-3].aveTemp + meteo[i-2].aveTemp + meteo[i-1].aveTemp) / 3.0
          else
            if i == 3
              tPrevious = (meteo[i-2].aveTemp + meteo[i-1].aveTemp) / 2.0
            else
              if i == 2
                tPrevious = meteo[i-1].aveTemp
              else
                tPrevious = meteo[1].aveTemp
              end
            end
          end
          penman = Meteo.computeEvapPenman(meteo[i].aveTemp,tPrevious,
                                                meteo[i].minTemp, meteo[i].maxTemp,
                                                meteo[i].radiation, meteo[i].relhum,
                                                meteo[i].windspeed, meteo[i].pressure)
          meteo[i].evapPenman = penman
        end
        DataManager.storePenman(station, year, meteo)
      catch e
        println("???ERROR in Control.computePenman: ", e)
      end
    finally
    end
  end

  function readTempAndHead(aCase :: Int64)
    try
      try
        baseDir = "/home/wesseling/DataDisk/Wesseling/Work/Waterstof/John/Data/"
        fileName = baseDir * "run10sim" * string(aCase) * "_pressureheadCday.csv"
        global simulatedHead = CSV.read(fileName, DataFrame)
        fileName = baseDir * "run10sim" * string(aCase) * "_tempertureCday.csv"
        global simulatedTemp = CSV.read(fileName, DataFrame)
      catch e
        println("???ERROR in Control.readTempAndHead: ", e)
      end
    finally
    end
  end

  function saveGrassResults()
    try
      try
        fileName = baseDir * "Grass/cropTranspiration.csv"
        myString = ""
        for case in 1:6
          for position in 1:4
            myString *= grassTranspiration[case,position]
            if position != 4
              myString *= ","
            end
          end
          myString *= "\n"
        end
        outfile = open(fileName, "w")
        println(outfile, myString)
        close(outfile)

        fileName = baseDir * "Grass/firstMowingDate.csv"
        myString = ""
        for case in 1:6
          for position in 1:4
            myString *= grassFirstMowingDate[case,position]
            if position != 4
              myString *= ","
            end
          end
          myString *= "\n"
        end
        outfile = open(fileName, "w")
        println(outfile, myString)
        close(outfile)

        fileName = baseDir * "Grass/harvest.csv"
        myString = ""
        for case in 1:6
          for position in 1:4
            myString *= grassHarvested[case,position]
            if position != 4
              myString *= ","
            end
          end
          myString *= "\n"
        end
        outfile = open(fileName, "w")
        println(outfile, myString)
        close(outfile)

        fileName = baseDir * "Grass/leftAtField.csv"
        myString = ""
        for case in 1:6
          for position in 1:4
            myString *= grassLeftAtField[case,position]
            if position != 4
              myString *= ","
            end
          end
          myString *= "\n"
        end
        outfile = open(fileName, "w")
        println(outfile, myString)
        close(outfile)

      catch e
        println("???ERROR in saveGrassResults: ",e)
      end
     finally
    end
  end

  function simulateGrassGrowth(aYear :: Int64)
    station = 344
    try
      try
        global year = aYear
        readMeteo(station, year)
#        plotEvaporation(year)
#        exit(0)
#         for p in 1:1
        for case in 1:6
          readTempAndHead(case)
          Grass.setSimulatedData(simulatedHead, simulatedTemp)
          Grass.resetMowingDays()
#         for position in 1:1
          for position in 4:-1:1
#            println(position)
            Grass.initialize(year, case, position)
            for i in 1:size(meteo,1)
              Grass.computeGrowth(meteo[i])
            end
#            exit(0)
            Grass.plotGrass()
#            println("After plotGrass")
            Grass.storeOutput()
#            println("After storeOutput")
            if position == 4
              Grass.stopGettingMowingDates()
#              println("After stopGettingMowingDays")
            end
            global grassTranspiration[case,position] = Grass.actualTranspiration
            global grassFirstMowingDate[case,position] = Grass.firstMowingDate
            global grassHarvested[case,position] = Grass.harvested
            global grassLeftAtField[case,position] = Grass.leftAtField
          end
        end
        saveGrassResults()
      catch e
        println("???ERROR in Control.simulateGrassGrowth: ", e)
      end
    finally
    end
  end

  function savePotatoResults()
    try
      try
        fileName = baseDir * "Potatoes/cropYield.csv"
        myString = ""
        for case in 1:6
          for position in 1:4
            myString *= string(floor(Int64,potatoYield[case,position]))
            if position != 4
              myString *= " & "
            end
          end
          myString *= "\\\\ \n"
        end
        outfile = open(fileName, "w")
        println(outfile, myString)
        close(outfile)

        fileName = baseDir * "Potatoes/cropYield_rel.csv"
        myString = ""
        for case in 1:6
          for position in 1:3
            x = 100.0 * (potatoYield[case,position] - potatoYield[case,4]) / potatoYield[case,4]
            myString *= @sprintf("%5.1f",x)
            if position != 3
              myString *= " & "
            end
          end
          myString *= "\\\\ \n"
        end
        outfile = open(fileName, "w")
        println(outfile, myString)
        close(outfile)

        fileName = baseDir * "Potatoes/temperatureYield.csv"
        myString = ""
        for case in 1:6
          for position in 1:4
            myString *= string(floor(Int64,potatoTemperature[case,position]))
            if position != 4
              myString *= " & "
            end
          end
          myString *= "\\\\ \n"
        end
        outfile = open(fileName, "w")
        println(outfile, myString)
        close(outfile)

        fileName = baseDir * "Potatoes/temperatureYield_rel.csv"
        myString = ""
        for case in 1:6
          for position in 1:3
            x = 100.0 * (potatoTemperature[case,position] - potatoTemperature[case,4]) / potatoTemperature[case,4]
            myString *= @sprintf("%5.1f",x)
            if position != 3
              myString *= " & "
            end
          end
          myString *= "\\\\ \n"
        end
        outfile = open(fileName, "w")
        println(outfile, myString)
        close(outfile)

        fileName = baseDir * "Potatoes/potentialYield.csv"
        myString = ""
        for case in 1:6
          for position in 1:4
            myString *= string(floor(Int64,potatoPotential[case,position]))
            if position != 4
              myString *= " & "
            end
          end
          myString *= "\\\\ \n"
        end
        outfile = open(fileName, "w")
        println(outfile, myString)
        close(outfile)

        fileName = baseDir * "Potatoes/potentialYield_rel.csv"
        myString = ""
        for case in 1:6
          for position in 1:3
            x = 100.0 * (potatoPotential[case,position] - potatoPotential[case,4]) / potatoPotential[case,4]
            myString *= @sprintf("%5.1f",x)
            if position != 3
              myString *= " & "
            end
          end
          myString *= "\\\\ \n"
        end
        outfile = open(fileName, "w")
        println(outfile, myString)
        close(outfile)

        fileName = baseDir * "Potatoes/moistureYield.csv"
        myString = ""
        for case in 1:6
          for position in 1:4
            myString *= string(floor(Int64,potatoMoisture[case,position]))
            if position != 4
              myString *= " & "
            end
          end
          myString *= "\\\\ \n"
        end
        outfile = open(fileName, "w")
        println(outfile, myString)
        close(outfile)

        fileName = baseDir * "Potatoes/moistureYield_rel.csv"
        myString = ""
        for case in 1:6
          for position in 1:3
            x = 100.0 * (potatoMoisture[case,position] - potatoMoisture[case,4]) / potatoMoisture[case,4]
            myString *= @sprintf("%5.1f",x)
            if position != 3
              myString *= " & "
            end
          end
          myString *= "\\\\ \n"
        end
        outfile = open(fileName, "w")
        println(outfile, myString)
        close(outfile)

        fileName = baseDir * "Potatoes/yieldFraction.csv"
        myString = ""
        for case in 1:6
          for position in 1:4
            x = potatoYield[case,position] / potatoPotential[case,position]
            myString *= @sprintf("%5.2f",x)
            if position != 4
              myString *= " & "
            end
          end
          myString *= "\\\\ \n"
        end
        outfile = open(fileName, "w")
        println(outfile, myString)
        close(outfile)



        fileName = baseDir * "Potatoes/cropEmergence.csv"
        myString = ""
        for case in 1:6
          for position in 1:4
            myString *= potatoDateEmergence[case,position]
            if position != 4
              myString *= ","
            end
          end
          myString *= "\n"
        end
        outfile = open(fileName, "w")
        println(outfile, myString)
        close(outfile)

        fileName = baseDir * "Potatoes/cropMature.csv"
        myString = ""
        for case in 1:6
          for position in 1:4
            myString *= potatoDateMature[case,position]
            if position != 4
              myString *= ","
            end
          end
          myString *= "\n"
        end
        outfile = open(fileName, "w")
        println(outfile, myString)
        close(outfile)

        fileName = baseDir * "Potatoes/cropTranspiration.csv"
        myString = ""
        for case in 1:6
          for position in 1:4
            myString *= string(floor(Int64,potatoTranspiration[case,position]))
            if position != 4
              myString *= ","
            end
          end
          myString *= "\n"
        end
        outfile = open(fileName, "w")
        println(outfile, myString)
        close(outfile)

      catch e
        println("???ERROR in savePotatoResults: ",e)
      end
     finally
    end
  end

  function simulatePotatoGrowth(aYear :: Int64)
    station = 344
    try
      try
        global year = aYear
        readMeteo(station, year)
#        plotEvaporation(year)
#        exit(0)
        for case in 1:6
          readTempAndHead(case)
          Potato.setSimulatedData(simulatedHead, simulatedTemp)
          for position in 4:-1:1
#            println(position)
            Potato.initialize(year, case, position)
            for i in 1:size(meteo,1)
              Potato.computeGrowth(meteo[i])
            end

            Potato.plotCrop()
            Potato.storeOutput(year)

            global potatoPotential[case,position] = Potato.potentialYield
            global potatoYield[case,position] = Potato.actualYield
            global potatoTemperature[case,position] = Potato.temperatureYield
            global potatoMoisture[case,position] = Potato.moistureYield
            global potatoDateEmergence[case,position] = Potato.actualDateEmergence
            global potatoDateMature[case,position] = Potato.actualDateMature
            global potatoTranspiration[case,position] = Potato.actualTranspiration

        end
       end
       savePotatoResults()
     catch e
        println("???ERROR in Control.simulatePotatoGrowth: ", e)
      end
    finally
    end
  end

end
