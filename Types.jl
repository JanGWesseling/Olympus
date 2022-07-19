module Types
  using Dates

  mutable struct Scenario
    scenarioid :: Int64
    femid :: Int64
    startTime :: DateTime
    endTime :: DateTime
    dtMax:: Float64
    meteostation :: Int64
    active :: Bool
  end

  mutable struct Node
    x :: Array{Float64}
  end

  mutable struct CubicElement
    corner :: Array{Int64}
  end

  mutable struct Element
    corner :: Array{Int64}
    volume :: Float64
    alpha :: Array{Float64}
  end

  mutable struct State
    temperature :: Float64
  end

  mutable struct Timing
    time :: DateTime
    previousTime :: DateTime
    timeStep :: Float64
    maxTimestep :: Float64
    outputDateTime :: DateTime
    outputRequired :: Bool
  end

  mutable struct Meteo
    year :: Int64
    dayofyear :: Int64
    radiation :: Float64
    minTemp :: Float64
    maxTemp :: Float64
    aveTemp :: Float64
    relhum :: Float64
    windspeed :: Float64
    pressure :: Float64
    prec :: Float64
    evapMakking :: Float64
    evapPenman :: Float64
    date :: DateTime
  end

  mutable struct Stage
    living :: Float64
    dead :: Float64
  end

  mutable struct Plant
    total :: Stage
    leaves :: Stage
    stem :: Stage
    storage :: Stage
    shoot :: Stage
    roots :: Stage
    rootingDepth :: Float64
    lai :: Float64
    laiExp :: Float64
    mowed :: Float64
    leaveAge :: Float64
    potentialPlantEvaporation :: Float64
    actualPlantEvaporation :: Float64
  end

  mutable struct CropYield
    theDate :: Date
    dayofyear :: Int64
    potentialEp :: Float64
    actualEp :: Float64
    dailyPotentialGrowth :: Plant
    dailyActualGrowth :: Plant
    dailyMoistureGrowth :: Plant
    dailyTemperatureGrowth :: Plant
    potential :: Plant
    actual :: Plant
    moisture :: Plant
    temperature :: Plant
  end

  mutable struct VGParams
    thetaR :: Float64
    thetaS :: Float64
    kS :: Float64
    alpha :: Float64
    l :: Float64
    n :: Float64
    m :: Float64
  end

end
