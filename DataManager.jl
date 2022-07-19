module DataManager
  using Dates
  using MySQL
  using DataFrames

  function readPositions(aFemId :: Int64, aDirection :: Int64)
    x = Array{Float64}(undef,1)
    myConnection = DBInterface.connect(MySQL.Connection, "127.0.0.1", "olympus", "Olympus.01", db="olympus")

    try
      try
        sqlSelect = "SELECT position FROM femgrid WHERE femid=" * string(aFemId) * " AND direction=" * string(aDirection) * " ORDER BY nodeid;"
        res = DBInterface.execute(myConnection, sqlSelect)
        df = DataFrame(res)
        resize!(x, size(df,1))
#        println(df)
        for i in 1:size(df,1)
          x[i] = convert(Float64, df[i,1])
        end
      catch e
        println("????Error in readPositions: ",e)
      end
    finally
      DBInterface.close!(myConnection)
    end
    return x
  end

  function storeNodes(aProfileId :: Int64, aNodes :: Array{Main.Control.Types.Node})
    status = 0
    myConnection = DBInterface.connect(MySQL.Connection, "127.0.0.1", "olympus", "Olympus.01", db="olympus")
    try
      try
        sqlDelete = "DELETE FROM femnode WHERE femid=" * string(aProfileId) * ";"
        res = DBInterface.execute(myConnection, sqlDelete)
#        println("After delete......")

        sqlInsert = "INSERT INTO femnode (femid,nodeid,x1,x2,x3) VALUE (?,?,?,?,?);"
        myStatement = DBInterface.prepare(myConnection, sqlInsert)
#        println("Before inserting")
        for i in 1:size(aNodes,1)
#          println(aProfileId,i,aNodes[i].x[1], aNodes[i].x[2], aNodes[i].x[3])
          res = DBInterface.execute(myStatement,[aProfileId,i,aNodes[i].x[1], aNodes[i].x[2], aNodes[i].x[3]])
        end
        DBInterface.close!(myStatement)
      catch e
        println("????Error in storeNodes: ", e)
        status = 1
      end
    finally
      DBInterface.close!(myConnection)
    end
    return status
  end

  function storeElements(aProfileId :: Int64, aElement :: Array{Main.Control.Types.Element})
    status = 0
    myConnection = DBInterface.connect(MySQL.Connection, "127.0.0.1", "olympus", "Olympus.01", db="olympus")
    try
      try
        sqlDelete = "DELETE FROM femelement WHERE femid=" * string(aProfileId) * ";"
        res = DBInterface.execute(myConnection, sqlDelete)

        sqlInsert = "INSERT INTO femelement (femid,elementid,localnode,nodeid) VALUE (?,?,?,?);"
        myStatement = DBInterface.prepare(myConnection, sqlInsert)
        for i in 1:size(aElement,1)
          for j in 1:size(aElement[i].corner, 1)
            res = DBInterface.execute(myStatement,[aProfileId,i,j,aElement[i].corner[j]])
          end
        end
        DBInterface.close!(myStatement)
      catch e
        println("????Error in storeElements: ", e)
        status = 1
      end
    finally
      DBInterface.close!(myConnection)
    end
    return status
  end

  function readScenarios()
    myScenario = Array{Main.Control.Types.Scenario}(undef,1)
    myConnection = DBInterface.connect(MySQL.Connection, "127.0.0.1", "olympus", "Olympus.01", db="olympus")

    try
      try
        sqlSelect = "SELECT * FROM scenario ORDER BY scenarioid;"
        res = DBInterface.execute(myConnection, sqlSelect)
        df = DataFrame(res)
        resize!(myScenario, size(df,1))
        println(df)
        for i in 1:size(df,1)
          id = convert(Int64, df[i,1])
          femid = convert(Int64,df[i,2])
          start = df[i,3]
          finish = df[i,4]
          dt = df[i,5]
          meteostation = convert(Int64,df[i,6])
          active = (df[i,7] == 1)
          myScenario[i] = Main.Control.Types.Scenario(id, femid, start, finish, dt, meteostation, active)
        end
      catch e
        println("????Error in readScenarios: ",e)
      end
    finally
      DBInterface.close!(myConnection)
    end
    return myScenario
  end

  function readMeteo(aStation :: Int64, aYear :: Int64)
    myMeteo = Array{Main.Control.Types.Meteo}(undef,1)
    myConnection = DBInterface.connect(MySQL.Connection, "127.0.0.1", "ltonoord","<Achterhoek2019>", db="lto")
    try
      try
        sqlSelect = "SELECT * FROM meteodata  WHERE meteostationid=" * string(aStation) * " AND year=" * string(aYear) * " ORDER BY dayofyear;"
        res = DBInterface.execute(myConnection, sqlSelect)
        df = DataFrame(res)
        rows = size(df,1)
        days = df[rows,3]
        resize!(myMeteo, days)
        for i in 1:rows
          day = convert(Int64, df[i,3])
          year = convert(Int64, df[i,2])
          radiation = df[i,5]
          minTemp = df[i,6]
          maxTemp = df[i,7]
          aveTemp = df[i,8]
          relhum = df[i,9]
          windspeed = df[i,10]
          pressure = df[1,11]
          prec = df[i,12]
          evap = df[i,13]
          penman = df[i,14]
          date = df[i,15]

          myMeteo[day] = Main.Control.Types.Meteo(year, day, radiation, minTemp, maxTemp, aveTemp, relhum, windspeed, pressure, prec, evap, penman, date)
        end
      catch e
        println("????Error in DataManager.readMeteo: ",e)
      end
    finally
      DBInterface.close!(myConnection)
    end
    return myMeteo
  end


  function deleteStates(aScenarioId :: Int64)
    status = 0
    myConnection = DBInterface.connect(MySQL.Connection, "127.0.0.1", "olympus", "Olympus.01", db="olympus")
    try
      try
        sqlDelete = "DELETE FROM states WHERE scenarioid=" * string(aScenarioId) * ";"
        res = DBInterface.execute(myConnection, sqlDelete)
      catch e
        println("????Error in deleteStates: ", e)
        status = 1
      end
    finally
      DBInterface.close!(myConnection)
    end
    return status
  end


  function storeStates(aScenarioId :: Int64, aTime :: DateTime, aState :: Array{Main.Control.Types.State})
    status = 0
    myConnection = DBInterface.connect(MySQL.Connection, "127.0.0.1", "olympus", "Olympus.01", db="olympus")
    try
      try
        sqlInsert = "INSERT INTO states (scenarioid,time,nodeid,temperature) VALUE (?,?,?,?);"
        myStatement = DBInterface.prepare(myConnection, sqlInsert)
        for i in 1:size(aState,1)
          res = DBInterface.execute(myStatement,[aScenarioId, aTime, i, aState[i].temperature])
        end
        DBInterface.close!(myStatement)
      catch e
        println("????Error in storeStates: ", e)
        status = 1
      end
    finally
      DBInterface.close!(myConnection)
    end
    return status
  end

  function storePenman(aStation :: Int64, aYear :: Int64, aData :: Array{Main.Control.Types.Meteo})
    status = 0
    myConnection = DBInterface.connect(MySQL.Connection, "127.0.0.1",  "ltonoord","<Achterhoek2019>", db="lto")
    try
      try
        sqlUpdate = "UPDATE meteodata SET penman=? WHERE meteostationid=? AND year=? AND dayofyear=?"
        myStatement = DBInterface.prepare(myConnection, sqlUpdate)
        for i in 1:size(aData,1)
          res = DBInterface.execute(myStatement,[aData[i].evapPenman, aStation, aYear, i])
        end
        DBInterface.close!(myStatement)
      catch e
        println("????Error in storePenman: ", e)
        status = 1
      end
    finally
      DBInterface.close!(myConnection)
    end
    return status
  end


end
