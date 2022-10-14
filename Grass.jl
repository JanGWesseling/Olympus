module Grass
  using Interpolations
  using Dates
  using OffsetArrays
  using Plots
  using Colors
  using CSV
  using DataFrames

  Gauss3x = [0.1127017, 0.5000000, 0.8872983]
  Gauss3w = [0.2777778, 0.4444444, 0.2777778]

  sensorDepth = [-0.1, -0.2, -0.3, -0.4, -0.5, -0.75, -1.0] # m
  sensorDistance = [0.0, 1.0, 2.0, 5.0, 10.0] # m

  CropFactorDaynumber = [1.0 1.0;
                        366.0 1.0]

  SpecificLeafAreaDaynumber = [1.00 0.0015;
                               80.00 0.0015;
                               300.00 0.0020;
                               366.00 0.0020]
#=
  AssimilationRateDayNumber = [1.00  40.00;
                               95.00  40.00;
                               200.00  35.00;
                               275.00  25.00;
                               366.00  25.00]
=#
  AssimilationRateDayNumber = [1.00  40.00;
                              95.00  45.00;
                             200.00  35.00;
                             275.00  26.00;
                             366.00  25.00]

  AmaxReductionAverageAirTemp =[0.00   0.00;
                                5.00   0.70;
                                15.00   1.00;
                                25.00   1.00;
                                40.00   0.00]

  AmaxReductionMinAirTemp = [0.00  0.000;
                             4.00  1.000]

  SenescenceReductionDaynumber = [1.00 1.0000;
                                  366.00 1.0000]

  GrowthPartToRootsDaynumber = [1.00 0.3000;
                                366.00 0.3000]

  GrowthPartToLeavesDaynumber = [1.00 0.6000;
                                366.00 0.6000]

  GrowthPartToStemsDaynumber = [1.00 0.4000;
                                366.00 0.4000]

  RelativeDeathRateOfRootsDaynumber = [1.0  0.0;
                                       180.0 0.02;
                                       366.0 0.02]

  RelativeDeathRateOfStemsDaynumber = [1.0 0.00;
                                       180.0 0.02;
                                       366.0 0.02]

  RelativeDeathRateOfLeavesByWaterStress = 0.05

  RootDepthRootWeight = [300.00   -0.20;
                         2500.00   -0.40]

  RelativeRootDensityRelativeRootDepth = [0.0   1.000;
                                          0.1   0.741;
                                          0.2   0.549;
                                          0.3   0.407;
                                          0.4   0.301;
                                          0.5   0.223;
                                          0.6   0.165;
                                          0.7   0.122;
                                          0.8   0.091;
                                          0.9   0.067;
                                          1.0   0.050]

  moistureUptakePressureHead = [-8000.0 0.0;
                                -400.0 1.0;
                                -1.0 1.0;
                                 0.0 0.0]

  moistureLimitEvaporativeDemand = [2.0  -800.0;
                                    5.0  -200.0]

  growthFactorTemperature = [5.0 0.1;
                            15.0 1.0;
                            20.0 1.0;
                            25.0 0.1;
                            30.0 0.05]

  initialWeight = 1000.0

  maximumRootingDepth = 0.05
  maximumRootWeight = 4000.0
  thresholdTempLeafAgeing = 0.0
  specificStemArea = 0.0004

  rml = 0.03
  rmr = 0.015
  rms = 0.015
  q10 = 2.0

  cvl = 0.685
  cvr = 0.694
  cvs = 0.662

  maxAgeOfLeaves = 30
  grassIsGrowing = false
  temperatureSum = 0.0
  lastDayMowedPotential = 0
  lastDayMowedActual = 0
  lastDayMowedMoisture = 0
  lastDayMowedTemperature = 0
  lastAllowedMowingDay = 289
  delayInPotentialRegrowth = 0
  delayInActualRegrowth = 0
  delayInMoistureRegrowth = 0
  delayInTemperatureRegrowth = 0
  tresholdForMowing = 4000.0
  tresholdForLastMowing = 2750.0

  latitude = 51.962
  longitude = 4.447

  kdif = 0.60
  kdir = 0.75
  eff  = 0.50

  rgrlai = 0.007
  relmf = 0.9

  year = 0
  position = 0
  profile = 0

  cropYield = OffsetArray{Main.Control.Types.CropYield}
  cropDate = Array{Dates.Date}(undef,365)
  cropYieldPotentialLiving = Array{Float64}(undef,365)
  cropYieldActualLiving = Array{Float64}(undef,365)
  cropYieldMoistureLiving = Array{Float64}(undef,365)
  cropYieldTemperatureLiving = Array{Float64}(undef,365)
  mowedActual = Array{Float64}(undef,365)
  mowedPotential = Array{Float64}(undef,365)
  mowedTemperature = Array{Float64}(undef,365)
  mowedMoisture = Array{Float64}(undef,365)
  laiActual = Array{Float64}(undef,365)
  laiPotential = Array{Float64}(undef,365)
  laiMoisture = Array{Float64}(undef,365)
  laiTemperature = Array{Float64}(undef,365)
  factorMoisture = Array{Float64}(undef,365)
  factorTemperature = Array{Float64}(undef,365)
  eppActual = Array{Float64}(undef,365)
  eppPotential = Array{Float64}(undef,365)
  eppMoisture = Array{Float64}(undef,365)
  eppTemperature = Array{Float64}(undef,365)
  epaActual = Array{Float64}(undef,365)
  epaPotential = Array{Float64}(undef,365)
  epaMoisture = Array{Float64}(undef,365)
  epaTemperature = Array{Float64}(undef,365)
  soilTemperatureAt10cm = Array{Float64}(undef,365)
  soilTemperatureAt20cm = Array{Float64}(undef,365)
  soilTemperatureAt40cm = Array{Float64}(undef,365)
  pressureHeadAt10cm = Array{Float64}(undef,365)
  pressureHeadAt20cm = Array{Float64}(undef,365)
  pressureHeadAt40cm = Array{Float64}(undef,365)

  mowingDayActual = Array{Int64}(undef,1)
  mowingDayPotential = Array{Int64}(undef,1)
  mowingDayMoisture = Array{Int64}(undef,1)
  mowingDayTemperature = Array{Int64}(undef,1)

  nMowingDaysActual = 0
  nMowingDaysPotential = 0
  nmowingDaysMoisture = 0
  nMowingDaysTemperature = 0

  gettingMowingDaysActual = true
  gettingMowingDaysPotential = true
  gettingMowingDaysTemperature = true
  gettingMowingDaysMoisture = true

  actualTranspiration = ""
  firstMowingDate = ""
  harvested = ""
  leftAtField = ""

  function interpolate(aData :: Array{Float64}, aX :: Float64)
    y = -999.0
    try
      try
        if aX < aData[1,1]
          y = aData[1,2]
        else
          if aX > aData[size(aData,1),1]
            y = aData[size(aData,2),2]
          else
            f = LinearInterpolation(aData[:,1], aData[:,2])
            y = f(aX)
          end
        end
      catch e
        println("???ERROR in interpolate: ",e)
      end
    finally
    end
    return y
  end

  function setSimulatedData(aHead :: DataFrame, aTemp :: DataFrame)
    try
      try
        global simulatedHead = aHead
        global simulatedTemperature = aTemp
      catch e
        println("???ERROR in Grass.setSimulatedData: ",e)
      end
    finally
#      println(simulatedHead[180,2])
    end
  end

  function resetMowingDays()
    try
      try
        resize!(mowingDayActual, 1)
        resize!(mowingDayPotential, 1)
        resize!(mowingDayTemperature, 1)
        resize!(mowingDayMoisture, 1)
        global nMowingDaysPotential = 0
        global nMowingDaysActual = 0
        global nMowingDaysMoisture = 0
        global nMowingDaysTemperature = 0
        global gettingMowingDaysActual = true
        global gettingMowingDaysPotential = true
        global gettingMowingDaysMoisture = true
        global gettingMowingDaysTemperature = true
      catch e
        println("???ERROR in clearMowingDays:", e)
      end
    finally
    end
  end

  function stopGettingMowingDates()
    try
      try
        global gettingMowingDaysActual = false
        global gettingMowingDaysPotential = false
        global gettingMowingDaysMoisture = false
        global gettingMowingDaysTemperature = false
      catch e
        println("???ERROR in stopGettingMowingDates:", e)
      end
    finally
    end
  end

  function initialize(aYear :: Int64, aProfile :: Int64, aPosition :: Int64)
    try
      try
        global year = aYear
        global profile = aProfile
        global position = aPosition
#        println(aYear)
        d = Date(aYear,1,1)
#        println(d)
        if isleapyear(d)
          global cropYield = OffsetArray{Main.Control.Types.CropYield}(undef,0:366)
        else
          global cropYield = OffsetArray{Main.Control.Types.CropYield}(undef,0:365)
        end
#        println(size(cropYield,1))

        for i in 0:size(cropYield,1)-1
  #        myYield = Main.Control.Types.Yield()
  #        cropYield[i] = myYield
          total = Main.Control.Types.Stage(0.0,0.0)
          leaves = Main.Control.Types.Stage(0.0,0.0)
          stem = Main.Control.Types.Stage(0.0,0.0)
          storage = Main.Control.Types.Stage(0.0,0.0)
          shoot = Main.Control.Types.Stage(0.0,0.0)
          roots = Main.Control.Types.Stage(0.0,0.0)
          actual = Main.Control.Types.Plant(total,leaves,stem,storage,shoot,roots,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0)

          total = Main.Control.Types.Stage(0.0,0.0)
          leaves = Main.Control.Types.Stage(0.0,0.0)
          stem = Main.Control.Types.Stage(0.0,0.0)
          storage = Main.Control.Types.Stage(0.0,0.0)
          shoot = Main.Control.Types.Stage(0.0,0.0)
          roots = Main.Control.Types.Stage(0.0,0.0)
          potential = Main.Control.Types.Plant(total,leaves,stem,storage,shoot,roots,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0)

          total = Main.Control.Types.Stage(0.0,0.0)
          leaves = Main.Control.Types.Stage(0.0,0.0)
          stem = Main.Control.Types.Stage(0.0,0.0)
          storage = Main.Control.Types.Stage(0.0,0.0)
          shoot = Main.Control.Types.Stage(0.0,0.0)
          roots = Main.Control.Types.Stage(0.0,0.0)
          moisture = Main.Control.Types.Plant(total,leaves,stem,storage,shoot,roots,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0)

          total = Main.Control.Types.Stage(0.0,0.0)
          leaves = Main.Control.Types.Stage(0.0,0.0)
          stem = Main.Control.Types.Stage(0.0,0.0)
          storage = Main.Control.Types.Stage(0.0,0.0)
          shoot = Main.Control.Types.Stage(0.0,0.0)
          roots = Main.Control.Types.Stage(0.0,0.0)
          temperature = Main.Control.Types.Plant(total,leaves,stem,storage,shoot,roots,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0)

          total = Main.Control.Types.Stage(0.0,0.0)
          leaves = Main.Control.Types.Stage(0.0,0.0)
          stem = Main.Control.Types.Stage(0.0,0.0)
          storage = Main.Control.Types.Stage(0.0,0.0)
          shoot = Main.Control.Types.Stage(0.0,0.0)
          roots = Main.Control.Types.Stage(0.0,0.0)
          dailyPotential = Main.Control.Types.Plant(total,leaves,stem,storage,shoot,roots,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0)

          total = Main.Control.Types.Stage(0.0,0.0)
          leaves = Main.Control.Types.Stage(0.0,0.0)
          stem = Main.Control.Types.Stage(0.0,0.0)
          storage = Main.Control.Types.Stage(0.0,0.0)
          shoot = Main.Control.Types.Stage(0.0,0.0)
          roots = Main.Control.Types.Stage(0.0,0.0)
          dailyActual = Main.Control.Types.Plant(total,leaves,stem,storage,shoot,roots,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0)

          total = Main.Control.Types.Stage(0.0,0.0)
          leaves = Main.Control.Types.Stage(0.0,0.0)
          stem = Main.Control.Types.Stage(0.0,0.0)
          storage = Main.Control.Types.Stage(0.0,0.0)
          shoot = Main.Control.Types.Stage(0.0,0.0)
          roots = Main.Control.Types.Stage(0.0,0.0)
          dailyMoisture = Main.Control.Types.Plant(total,leaves,stem,storage,shoot,roots,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0)

          total = Main.Control.Types.Stage(0.0,0.0)
          leaves = Main.Control.Types.Stage(0.0,0.0)
          stem = Main.Control.Types.Stage(0.0,0.0)
          storage = Main.Control.Types.Stage(0.0,0.0)
          shoot = Main.Control.Types.Stage(0.0,0.0)
          roots = Main.Control.Types.Stage(0.0,0.0)
          dailyTemperature = Main.Control.Types.Plant(total,leaves,stem,storage,shoot,roots,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0)

          global cropYield[i] = Main.Control.Types.CropYield(d, i, 0.0, 0.0, dailyPotential, dailyActual,
            dailyMoisture, dailyTemperature, potential, actual, moisture, temperature)
          d += Dates.Day(1)
        end

        fr = interpolate(GrowthPartToRootsDaynumber, 0.0)
        fl = interpolate(GrowthPartToLeavesDaynumber, 0.0)
        fs = interpolate(GrowthPartToStemsDaynumber, 0.0)

        global cropYield[0].potential.roots.living = fr * initialWeight
        global cropYield[0].potential.leaves.living = (1.0 - fr) * fl * initialWeight
        global cropYield[0].potential.stem.living = (1.0 - fr) * fs * initialWeight
        global cropYield[0].potential.shoot.living = (1.0 - fr) * (1.0 - fl - fs) * initialWeight
        global cropYield[0].potential.total.dead = 0.0
        global cropYield[0].potential.roots.dead = 0.0
        global cropYield[0].potential.leaves.dead = 0.0
        global cropYield[0].potential.stem.dead = 0.0
        global cropYield[0].potential.shoot.dead = 0.0
        global cropYield[0].potential.rootingDepth = interpolate(RootDepthRootWeight,cropYield[0].potential.roots.living)
        global cropYield[0].potential.lai = cropYield[0].potential.leaves.living * interpolate(SpecificLeafAreaDaynumber, 0.0)
        global cropYield[0].potential.laiExp = cropYield[0].potential.lai
        global cropYield[0].potential.total.living = cropYield[0].potential.leaves.living + cropYield[0].potential.stem.living

        global cropYield[0].actual.total.living = cropYield[0].potential.total.living
        global cropYield[0].actual.roots.living = cropYield[0].potential.roots.living
        global cropYield[0].actual.leaves.living = cropYield[0].potential.leaves.living
        global cropYield[0].actual.stem.living = cropYield[0].potential.stem.living
        global cropYield[0].actual.shoot.living = cropYield[0].potential.shoot.living
        global cropYield[0].actual.total.dead = cropYield[0].potential.total.dead
        global cropYield[0].actual.roots.dead = cropYield[0].potential.roots.dead
        global cropYield[0].actual.leaves.dead = cropYield[0].potential.leaves.dead
        global cropYield[0].actual.stem.dead = cropYield[0].potential.stem.dead
        global cropYield[0].actual.shoot.dead = cropYield[0].potential.shoot.dead
        global cropYield[0].actual.rootingDepth = cropYield[0].potential.rootingDepth
        global cropYield[0].actual.lai = cropYield[0].potential.lai
        global cropYield[0].actual.laiExp = cropYield[0].potential.laiExp

        global cropYield[0].moisture.total.living = cropYield[0].potential.total.living
        global cropYield[0].moisture.roots.living = cropYield[0].potential.roots.living
        global cropYield[0].moisture.leaves.living = cropYield[0].potential.leaves.living
        global cropYield[0].moisture.stem.living = cropYield[0].potential.stem.living
        global cropYield[0].moisture.shoot.living = cropYield[0].potential.shoot.living
        global cropYield[0].moisture.total.dead = cropYield[0].potential.total.dead
        global cropYield[0].moisture.roots.dead = cropYield[0].potential.roots.dead
        global cropYield[0].moisture.leaves.dead = cropYield[0].potential.leaves.dead
        global cropYield[0].moisture.stem.dead = cropYield[0].potential.stem.dead
        global cropYield[0].moisture.shoot.dead = cropYield[0].potential.shoot.dead
        global cropYield[0].moisture.rootingDepth = cropYield[0].potential.rootingDepth
        global cropYield[0].moisture.lai = cropYield[0].potential.lai
        global cropYield[0].moisture.laiExp = cropYield[0].potential.laiExp

        global cropYield[0].temperature.total.living = cropYield[0].potential.total.living
        global cropYield[0].temperature.roots.living = cropYield[0].potential.roots.living
        global cropYield[0].temperature.leaves.living = cropYield[0].potential.leaves.living
        global cropYield[0].temperature.stem.living = cropYield[0].potential.stem.living
        global cropYield[0].temperature.shoot.living = cropYield[0].potential.shoot.living
        global cropYield[0].temperature.total.dead = cropYield[0].potential.total.dead
        global cropYield[0].temperature.roots.dead = cropYield[0].potential.roots.dead
        global cropYield[0].temperature.leaves.dead = cropYield[0].potential.leaves.dead
        global cropYield[0].temperature.stem.dead = cropYield[0].potential.stem.dead
        global cropYield[0].temperature.shoot.dead = cropYield[0].potential.shoot.dead
        global cropYield[0].temperature.rootingDepth = cropYield[0].potential.rootingDepth
        global cropYield[0].temperature.lai = cropYield[0].potential.lai
        global cropYield[0].temperature.laiExp = cropYield[0].potential.laiExp

#        println(cropYield[0].actualWeight)

        global grassIsGrowing = false
        global temperatureSum = 0.0
      catch e
        println("???ERROR in Grass.initialize: ",e)
      end
    finally
    end
  end

  function copyPotentialValues(aDay :: Int64)
    try
      try
        d = aDay
        global cropYield[d].potential.total.living = cropYield[d-1].potential.total.living
        global cropYield[d].potential.roots.living = cropYield[d-1].potential.roots.living
        global cropYield[d].potential.leaves.living = cropYield[d-1].potential.leaves.living
        global cropYield[d].potential.stem.living = cropYield[d-1].potential.stem.living
        global cropYield[d].potential.shoot.living = cropYield[d-1].potential.shoot.living
        global cropYield[d].potential.total.dead = cropYield[d-1].potential.total.dead
        global cropYield[d].potential.roots.dead = cropYield[d-1].potential.roots.dead
        global cropYield[d].potential.leaves.dead = cropYield[d-1].potential.leaves.dead
        global cropYield[d].potential.stem.dead = cropYield[d-1].potential.stem.dead
        global cropYield[d].potential.shoot.dead = cropYield[d-1].potential.shoot.dead
        global cropYield[d].potential.rootingDepth = cropYield[d-1].potential.rootingDepth
        global cropYield[d].potential.lai = cropYield[d-1].potential.lai
        global cropYield[d].potential.laiExp = cropYield[d-1].potential.laiExp

        global cropYield[d].dailyPotentialGrowth.total.living = cropYield[d-1].dailyPotentialGrowth.total.living
        global cropYield[d].dailyPotentialGrowth.roots.living = cropYield[d-1].dailyPotentialGrowth.roots.living
        global cropYield[d].dailyPotentialGrowth.leaves.living = cropYield[d-1].dailyPotentialGrowth.leaves.living
        global cropYield[d].dailyPotentialGrowth.stem.living = cropYield[d-1].dailyPotentialGrowth.stem.living
        global cropYield[d].dailyPotentialGrowth.shoot.living = cropYield[d-1].dailyPotentialGrowth.shoot.living
        global cropYield[d].dailyPotentialGrowth.total.dead = cropYield[d-1].dailyPotentialGrowth.total.dead
        global cropYield[d].dailyPotentialGrowth.roots.dead = cropYield[d-1].dailyPotentialGrowth.roots.dead
        global cropYield[d].dailyPotentialGrowth.leaves.dead = cropYield[d-1].dailyPotentialGrowth.leaves.dead
        global cropYield[d].dailyPotentialGrowth.stem.dead = cropYield[d-1].dailyPotentialGrowth.stem.dead
        global cropYield[d].dailyPotentialGrowth.shoot.dead = cropYield[d-1].dailyPotentialGrowth.shoot.dead
        global cropYield[d].dailyPotentialGrowth.rootingDepth = cropYield[d-1].dailyPotentialGrowth.rootingDepth
        global cropYield[d].dailyPotentialGrowth.lai = cropYield[d-1].dailyPotentialGrowth.lai
        global cropYield[d].dailyPotentialGrowth.laiExp = cropYield[d-1].dailyPotentialGrowth.laiExp
      catch e
        println("????ERROR in Grass.copyPotentialValues: ", e)
      end
    finally
    end
  end

  function copyActualValues(aDay :: Int64)
    try
      try
        d = aDay
        global cropYield[d].actual.total.living = cropYield[d-1].actual.total.living
        global cropYield[d].actual.roots.living = cropYield[d-1].actual.roots.living
        global cropYield[d].actual.leaves.living = cropYield[d-1].actual.leaves.living
        global cropYield[d].actual.stem.living = cropYield[d-1].actual.stem.living
        global cropYield[d].actual.shoot.living = cropYield[d-1].actual.shoot.living
        global cropYield[d].actual.total.dead = cropYield[d-1].actual.total.dead
        global cropYield[d].actual.roots.dead = cropYield[d-1].actual.roots.dead
        global cropYield[d].actual.leaves.dead = cropYield[d-1].actual.leaves.dead
        global cropYield[d].actual.stem.dead = cropYield[d-1].actual.stem.dead
        global cropYield[d].actual.shoot.dead = cropYield[d-1].actual.shoot.dead
        global cropYield[d].actual.rootingDepth = cropYield[d-1].actual.rootingDepth
        global cropYield[d].actual.lai = cropYield[d-1].actual.lai
        global cropYield[d].actual.laiExp = cropYield[d-1].actual.laiExp

        global cropYield[d].dailyActualGrowth.total.living = cropYield[d-1].dailyPotentialGrowth.total.living
        global cropYield[d].dailyActualGrowth.roots.living = cropYield[d-1].dailyActualGrowth.roots.living
        global cropYield[d].dailyActualGrowth.leaves.living = cropYield[d-1].dailyActualGrowth.leaves.living
        global cropYield[d].dailyActualGrowth.stem.living = cropYield[d-1].dailyActualGrowth.stem.living
        global cropYield[d].dailyActualGrowth.shoot.living = cropYield[d-1].dailyActualGrowth.shoot.living
        global cropYield[d].dailyActualGrowth.total.dead = cropYield[d-1].dailyActualGrowth.total.dead
        global cropYield[d].dailyActualGrowth.roots.dead = cropYield[d-1].dailyActualGrowth.roots.dead
        global cropYield[d].dailyActualGrowth.leaves.dead = cropYield[d-1].dailyActualGrowth.leaves.dead
        global cropYield[d].dailyActualGrowth.stem.dead = cropYield[d-1].dailyActualGrowth.stem.dead
        global cropYield[d].dailyActualGrowth.shoot.dead = cropYield[d-1].dailyActualGrowth.shoot.dead
        global cropYield[d].dailyActualGrowth.rootingDepth = cropYield[d-1].dailyActualGrowth.rootingDepth
        global cropYield[d].dailyActualGrowth.lai = cropYield[d-1].dailyActualGrowth.lai
        global cropYield[d].dailyActualGrowth.laiExp = cropYield[d-1].dailyActualGrowth.laiExp
      catch e
        println("????ERROR in Grass.copyActualValues: ", e)
      end
    finally
    end
  end

  function copyMoistureValues(aDay :: Int64)
    try
      try
        d = aDay
        global cropYield[d].moisture.total.living = cropYield[d-1].moisture.total.living
        global cropYield[d].moisture.roots.living = cropYield[d-1].moisture.roots.living
        global cropYield[d].moisture.leaves.living = cropYield[d-1].moisture.leaves.living
        global cropYield[d].moisture.stem.living = cropYield[d-1].moisture.stem.living
        global cropYield[d].moisture.shoot.living = cropYield[d-1].moisture.shoot.living
        global cropYield[d].moisture.total.dead = cropYield[d-1].moisture.total.dead
        global cropYield[d].moisture.roots.dead = cropYield[d-1].moisture.roots.dead
        global cropYield[d].moisture.leaves.dead = cropYield[d-1].moisture.leaves.dead
        global cropYield[d].moisture.stem.dead = cropYield[d-1].moisture.stem.dead
        global cropYield[d].moisture.shoot.dead = cropYield[d-1].moisture.shoot.dead
        global cropYield[d].moisture.rootingDepth = cropYield[d-1].moisture.rootingDepth
        global cropYield[d].moisture.lai = cropYield[d-1].moisture.lai
        global cropYield[d].moisture.laiExp = cropYield[d-1].moisture.laiExp

        global cropYield[d].dailyMoistureGrowth.total.living = cropYield[d-1].dailyPotentialGrowth.total.living
        global cropYield[d].dailyMoistureGrowth.roots.living = cropYield[d-1].dailyMoistureGrowth.roots.living
        global cropYield[d].dailyMoistureGrowth.leaves.living = cropYield[d-1].dailyMoistureGrowth.leaves.living
        global cropYield[d].dailyMoistureGrowth.stem.living = cropYield[d-1].dailyMoistureGrowth.stem.living
        global cropYield[d].dailyMoistureGrowth.shoot.living = cropYield[d-1].dailyMoistureGrowth.shoot.living
        global cropYield[d].dailyMoistureGrowth.total.dead = cropYield[d-1].dailyMoistureGrowth.total.dead
        global cropYield[d].dailyMoistureGrowth.roots.dead = cropYield[d-1].dailyMoistureGrowth.roots.dead
        global cropYield[d].dailyMoistureGrowth.leaves.dead = cropYield[d-1].dailyMoistureGrowth.leaves.dead
        global cropYield[d].dailyMoistureGrowth.stem.dead = cropYield[d-1].dailyMoistureGrowth.stem.dead
        global cropYield[d].dailyMoistureGrowth.shoot.dead = cropYield[d-1].dailyMoistureGrowth.shoot.dead
        global cropYield[d].dailyMoistureGrowth.rootingDepth = cropYield[d-1].dailyMoistureGrowth.rootingDepth
        global cropYield[d].dailyMoistureGrowth.lai = cropYield[d-1].dailyMoistureGrowth.lai
        global cropYield[d].dailyMoistureGrowth.laiExp = cropYield[d-1].dailyMoistureGrowth.laiExp
      catch e
        println("????ERROR in Grass.copyMoistureValues: ", e)
      end
    finally
    end
  end

  function copyTemperatureValues(aDay :: Int64)
    try
      try
        d = aDay
        global cropYield[d].temperature.total.living = cropYield[d-1].temperature.total.living
        global cropYield[d].temperature.roots.living = cropYield[d-1].temperature.roots.living
        global cropYield[d].temperature.leaves.living = cropYield[d-1].temperature.leaves.living
        global cropYield[d].temperature.stem.living = cropYield[d-1].temperature.stem.living
        global cropYield[d].temperature.shoot.living = cropYield[d-1].temperature.shoot.living
        global cropYield[d].temperature.total.dead = cropYield[d-1].temperature.total.dead
        global cropYield[d].temperature.roots.dead = cropYield[d-1].temperature.roots.dead
        global cropYield[d].temperature.leaves.dead = cropYield[d-1].temperature.leaves.dead
        global cropYield[d].temperature.stem.dead = cropYield[d-1].temperature.stem.dead
        global cropYield[d].temperature.shoot.dead = cropYield[d-1].temperature.shoot.dead
        global cropYield[d].temperature.rootingDepth = cropYield[d-1].temperature.rootingDepth
        global cropYield[d].temperature.lai = cropYield[d-1].temperature.lai
        global cropYield[d].temperature.laiExp = cropYield[d-1].temperature.laiExp

        global cropYield[d].dailyTemperatureGrowth.total.living = cropYield[d-1].dailyPotentialGrowth.total.living
        global cropYield[d].dailyTemperatureGrowth.roots.living = cropYield[d-1].dailyTemperatureGrowth.roots.living
        global cropYield[d].dailyTemperatureGrowth.leaves.living = cropYield[d-1].dailyTemperatureGrowth.leaves.living
        global cropYield[d].dailyTemperatureGrowth.stem.living = cropYield[d-1].dailyTemperatureGrowth.stem.living
        global cropYield[d].dailyTemperatureGrowth.shoot.living = cropYield[d-1].dailyTemperatureGrowth.shoot.living
        global cropYield[d].dailyTemperatureGrowth.total.dead = cropYield[d-1].dailyTemperatureGrowth.total.dead
        global cropYield[d].dailyTemperatureGrowth.roots.dead = cropYield[d-1].dailyTemperatureGrowth.roots.dead
        global cropYield[d].dailyTemperatureGrowth.leaves.dead = cropYield[d-1].dailyTemperatureGrowth.leaves.dead
        global cropYield[d].dailyTemperatureGrowth.stem.dead = cropYield[d-1].dailyTemperatureGrowth.stem.dead
        global cropYield[d].dailyTemperatureGrowth.shoot.dead = cropYield[d-1].dailyTemperatureGrowth.shoot.dead
        global cropYield[d].dailyTemperatureGrowth.rootingDepth = cropYield[d-1].dailyTemperatureGrowth.rootingDepth
        global cropYield[d].dailyTemperatureGrowth.lai = cropYield[d-1].dailyTemperatureGrowth.lai
        global cropYield[d].dailyTemperatureGrowth.laiExp = cropYield[d-1].dailyTemperatureGrowth.laiExp
      catch e
        println("????ERROR in Grass.copyTemperatureValues: ", e)
      end
    finally
    end
  end

  function beforeGrassGrowth(aMeteo :: Main.Control.Types.Meteo)
    try
      try
        d = aMeteo.dayofyear
        poentialEp = aMeteo.evapPenman
        actualEp = 0.0

        copyPotentialValues(d)
        copyActualValues(d)
        copyMoistureValues(d)
        copyTemperatureValues(d)
        global temperatureSum += max(aMeteo.aveTemp, 0.0)
        if temperatureSum > 200.0
          global grassIsGrowing = true
          global lastDayMowedActual = d
          global lastDayMowedPotential = d
          global lastDayMowedMoisture = d
          global lastDayMowedTemperature = d
        end
      catch e
        println("???ERROR in Grass.beforeGrassGrowth: ",e)
      end
    finally
    end
  end

  function potentialGrassGrowth(aMeteo :: Main.Control.Types.Meteo, aDay :: Int64)
    try
      try
        fMoisture = 1.0
        fTemperature = 1.0
        mowed = 0.0

        if aDay <= lastDayMowedPotential + delayInPotentialRegrowth
          copyPotentialValues(aDay)
        else
          t =convert(Float64, aDay)
          avrad = 1000.0 * aMeteo.radiation
          scv = 0.2

#         Declination and solar constant for this day
          declination = -asin(sind(23.45) * cos(2.0 * pi * (t+10) /365.0))
          solarConstant  = 1370.0 * (1.0 + 0.033 * cos(2.0*pi*t/365.0))

#         calculation of daylength from intermediate variables
#         SINLD, COSLD and AOB
          sinld = sind(latitude)*sin(declination)
          cosld = cosd(latitude)*cos(declination)
          aob = sinld/cosld

#         Calculate solution for base=0 degrees
          if abs(aob) <= 1.0
            daylength = 12.0 * (1.0 + 2.0 * asin(aob) / pi)
#           integrals of sine of solar height
            dsinb  = 3600.0 * (daylength * sinld + 24.0 * cosld * sqrt(1.0-aob*aob)/pi)
            dsinbe = 3600.0 * (daylength * (sinld + 0.40 * (sinld* sinld + cosld * cosld * 0.5)) + 12.0 * cosld * (2.0 + 3.0 * 0.4 * sinld) * sqrt(1.0 - aob * aob)/pi)
          else
            if aob > 1.0
              daylength = 24.0
            end
            if aob < 1.0
              daylength =  0.0
            end
#           integrals of sine of solar height
            dsinb  = 3600.0 * (daylength * sinld)
            dsinbe = 3600.0 * (daylength * (sinld + 0.4 * (sinld * sinld + cosld * cosld * 0.5)))
          end

#         Calculate solution for base =-4 (ANGLE) degrees
          angle = -4.0
          aob_corr = (-sind(angle) + sinld)/cosld
          if abs(aob_corr) <= 1.0
            daylp = 12.0 * (1.0 + 2.0 * asin(aob_corr) / pi)
          else
            if aob_corr > 1.0
              daylp = 24.0
            end
            if aob_corr < -1.0
              daylp =  0.0
            end
          end

#         extraterrestrial radiation and atmospheric transmission
          angot  = solarConstant * dsinb
#         Check for daylength=0 as in that case the angot radiation is 0 as well
          atmtr = 0.0
          if daylength > 0.0
            atmtr = avrad / angot
          end

#         estimate fraction diffuse irradiation
          frdif = 0.0
          if atmtr > 0.75
            frdif = 0.23
          end
          if atmtr < 0.75 && atmtr > 0.35
            frdif = 1.33 - 1.46 * atmtr
          end
          if atmtr <= 0.35 && atmtr > 0.07
            frdif = 1.0 - 2.3 * (atmtr - 0.07) * (atmtr - 0.07)
          end
          if atmtr <= 0.07
            frdif = 1.0
          end
          difpp = frdif * atmtr * 0.5 * solarConstant

          amax = interpolate(AssimilationRateDayNumber,t) * interpolate(AmaxReductionAverageAirTemp, aMeteo.aveTemp)

#         potential growth

#          cropYield[aDay-1].potential.lai = 5.0
          dtga  = 0.0
          if amax > 0.0 && cropYield[aDay-1].potential.lai > 0.0
            for i in 1:3
              hour = 12.0 + daylength * (Gauss3x[i] - 0.5)
              sinb = max(0.0, sinld + cosld *cos(2.0 * pi * (hour + 12.0) / 24.0))
              par = 0.5 * avrad * sinb * (1.0 + 0.4 * sinb) / dsinbe
              pardif = min(par, sinb * difpp)
              pardir = par - pardif

#             extinction coefficients KDIF,KDIRBL,KDIRT, start of assim
              refh   = (1.0 - sqrt(1.0 - scv)) / (1.0 + sqrt(1.0 - scv))
              refs   = refh * 2.0 / (1.0 + 1.6 * sinb)
              kdirbl = (0.5 / sinb) * kdif / (0.8 * sqrt(1.0 - scv))
              kdirt  = kdirbl * sqrt(1.0 - scv)

#             three-point Gaussian integration over LAI
              fgros  = 0.0
              for j in 1:3
                laic   = cropYield[aDay-1].potential.lai * Gauss3x[j]
#               absorbed diffuse radiation (VISDF),light from direct
#               origine (VIST) and direct light(VISD)
                visdf  = (1.0 - refs) * pardif * kdif * exp(-kdif * laic)
                vist   = (1.0 - refs) * pardir * kdirt * exp(-kdirt * laic)
                visd   = (1.0 - scv) * pardir * kdirbl * exp(-kdirbl*laic)
#               absorbed flux in W/m2 for shaded leaves and assimilation
                visshd = visdf + vist - visd
                fgrsh  = amax * (1.0 - exp(-visshd * eff / max(2.0,amax)))
#               direct light absorbed by leaves perpendicular on direct
#               beam and assimilation of sunlit leaf area
                vispp  = (1.0 - scv) * pardir / sinb
                fgrsun = fgrsh
                if vispp > 0.0
                  fgrsun = amax * (1.0 - (amax - fgrsh) * (1.0-exp(-vispp * eff / max(2.0,amax))) / (eff * vispp))
                end
#               fraction of sunlit leaf area (FSLLA) and local assimilation rate (FGL)
                fslla  = exp(-kdirbl * laic)
                fgl    = fslla * fgrsun + (1.0 - fslla) * fgrsh
#               integration
                fgros  += fgl * Gauss3w[j]
              end
              fgros  *=  cropYield[aDay-1].potential.lai
#             end of assim
              dtga += fgros * Gauss3w[i]
            end
            dtga = dtga * daylength
          end

#          println(dtga)
#          exit(0)

#         correction for low minimum temperature
          dtga *= interpolate(AmaxReductionMinAirTemp, aMeteo.minTemp)
#         potential assimilation in kg ch2o per ha
          pgass = dtga * 30.0 / 44.0

#         water stress reduction of pgass to gass and limited attainable maximum
           gass = pgass * fTemperature * fMoisture

#         relative management factor that reduces crop growth
          gass = gass * relmf

#         respiration and partitioning of carbohydrates between growth and maintenance respiration
          rmres = (rmr * cropYield[aDay-1].potential.roots.living +
                    rml * cropYield[aDay-1].potential.leaves.living +
                    rms * cropYield[aDay-1].potential.stem.living) *
                    interpolate(SenescenceReductionDaynumber,t)
          teff = q10^((aMeteo.aveTemp - 25.0) / 10.0)
          mres = min(gass, rmres * teff)
          asrc = gass - mres
#         println(t,"   ",asrc,"   ",gass,"   ",mres,"    ",rmres,"    ",teff)

#         partitioning factors
          fr = interpolate(GrowthPartToRootsDaynumber, t)
          fl = interpolate(GrowthPartToLeavesDaynumber, t)
          fs = interpolate(GrowthPartToStemsDaynumber, t)
#         check on partitioning
          fcheck = fr + (fl + fs) * (1.0 - fr) - 1.0
          if abs(fcheck) > 0.0001
            println("???ERROR in partitioning: sum=",fcheck)
          end

#         dry matter increase
          cvf = 1.0 / ((fl / cvl + fs / cvs) * (1.0 - fr) +fr / cvr)
          dmi = cvf * asrc
#          println(dmi)
#         check on carbon balance
          ccheck = (gass - mres - (fr + (fl + fs) * (1.0 - fr)) * dmi / cvf) / max(0.0001,gass)
          if abs(ccheck) > 0.0001
            println("???ERROR: The carbon balance is not correct")
          end

#         growth rate by plant organ

#         growth rate roots and aerial parts
#         after reaching a live weight of wrtmax(default 2500 kg), the
#         growth of the roots is balanced by the death of root tissue
          deathRateOfRoots = fTemperature * cropYield[aDay-1].potential.roots.living * interpolate(RelativeDeathRateOfRootsDaynumber,t)
          growthRateOfRoots = fr * dmi
          newWeight = cropYield[aDay-1].potential.roots.living + growthRateOfRoots - deathRateOfRoots
          if newWeight > maximumRootWeight
            growthRateOfRoots = max(0.0, growthRateOfRoots  - (newWeight - maximumRootWeight))
            deathRateOfRoots = max(0.0, cropYield[aDay-1].potential.roots.living + growthRateOfRoots - maximumRootWeight)
          end
#          println("gr=", growthRateOfRoots,"   dr=", deathRateOfRoots, "  living=", cropYield[aDay-1].potential.roots.living, "  dead=",cropYield[aDay-1].potential.roots.dead)

#         growth rate leaves
#         weight of new leaves
          admi = (1.0 - fr) * dmi
          growthRateLeaves = fl * admi

#         death of leaves due to water stress or high lai
          dslv1 = 0.0
          laicr = 3.2/kdif
          dslv2 = cropYield[aDay-1].potential.leaves.living * max(0.0, min(0.03,0.03 * (cropYield[aDay-1].potential.lai - laicr) / laicr))
          deathRateLeavesLai = max(dslv1, dslv2)

#         death of leaves due to exceeding life span;
#         leaf death is imposed on array until no more leaves have
#         to die or all leaves are gone

          deathRateLeavesAge = 0.0
          fysdel = max(0.0, (aMeteo.aveTemp - thresholdTempLeafAgeing)/(35.0 - thresholdTempLeafAgeing))
          for i in lastDayMowedPotential + 1 : aDay-1
            cropYield[i].potential.leaveAge += fysdel
            if cropYield[i].potential.leaveAge > maxAgeOfLeaves && cropYield[i].potential.leaves.living > 0.0
              if cropYield[i].dailyPotentialGrowth.leaves.living > 0.0
                deathRateLeavesAge += cropYield[i].dailyPotentialGrowth.leaves.living
                global cropYield[i].dailyPotentialGrowth.leaves.dead += cropYield[i].dailyPotentialGrowth.leaves.living
                global cropYield[i].dailyPotentialGrowth.leaves.living = 0.0
              end
            end
          end

#         leaf area not to exceed exponential growth curve
          glaiexp = 0.0
          slatpot = interpolate(SpecificLeafAreaDaynumber, t)
          if cropYield[aDay-1].potential.laiExp < 6.0
            dteff = max(0.0, aMeteo.aveTemp - thresholdTempLeafAgeing)
            glaiexp = cropYield[aDay-1].potential.laiExp * dteff * rgrlai
            glasol = growthRateLeaves * slatpot
            gla = min(glaiexp,glasol)
#           adjustment of specific leaf area of youngest leaf class
            if growthRateLeaves > 0.0
              slat = gla/growthRateLeaves
            end
          end

#         lai in case of exponential growthRateStem
          global cropYield[aDay].potential.laiExp += glaiexp

#         growth rate stems
          wst = cropYield[aDay-1].potential.stem.living
          growthRateStem = fs*admi
#         death of stems due to water stress is zero in case of potential growth
          deathRateStem1 = 0.0
#         death of stems due to ageing
          deathRateStem2 = interpolate(RelativeDeathRateOfStemsDaynumber, t) * wst
          deathRateStem = deathRateStem1 + deathRateStem2

#         integrals of the crop
#         dry weight of living plant organs
          global cropYield[aDay].dailyPotentialGrowth.leaves.living = growthRateLeaves - deathRateLeavesLai
          global cropYield[aDay].potential.leaves.living = max(0.0, cropYield[aDay-1].potential.leaves.living + growthRateLeaves - deathRateLeavesLai - deathRateLeavesAge)
          global cropYield[aDay].dailyPotentialGrowth.roots.living = growthRateOfRoots
          global cropYield[aDay].potential.roots.living = cropYield[aDay-1].potential.roots.living + growthRateOfRoots - deathRateOfRoots
          global cropYield[aDay].dailyPotentialGrowth.stem.living = growthRateStem - deathRateStem
          global cropYield[aDay].potential.stem.living = cropYield[aDay-1].potential.stem.living + growthRateStem - deathRateStem

#         dry weight of dead plant organs (roots,leaves & stems)
          global cropYield[aDay].dailyPotentialGrowth.roots.dead =  deathRateOfRoots
          global cropYield[aDay].potential.roots.dead = cropYield[aDay-1].potential.roots.dead + deathRateOfRoots
          global cropYield[aDay].potential.leaves.dead = cropYield[aDay-1].potential.leaves.dead + deathRateLeavesLai + deathRateLeavesAge
          global cropYield[aDay].dailyPotentialGrowth.stem.dead = deathRateStem
          global cropYield[aDay].potential.stem.dead = cropYield[aDay-1].potential.stem.dead + deathRateStem

#         total
          global cropYield[aDay].potential.total.living = cropYield[aDay].potential.leaves.living + cropYield[aDay].potential.stem.living
          global cropYield[aDay].potential.total.dead = cropYield[aDay].potential.leaves.dead + cropYield[aDay].potential.stem.dead

#         mowing
          mowingRequired = false
#          println(aDay, "   ", cropYield[aDay].potential.total.living + cropYield[aDay].potential.total.dead, "    ", gettingMowingDaysPotential)
          if gettingMowingDaysPotential
            if (cropYield[aDay].potential.total.living + cropYield[aDay].potential.total.dead > tresholdForMowing && aDay < lastAllowedMowingDay) ||
               (aDay == lastAllowedMowingDay && cropYield[aDay].potential.total.living + cropYield[aDay].potential.total.dead >= tresholdForLastMowing)
              global mowingRequired = true
              global nMowingDaysPotential += 1
              resize!(mowingDayPotential, nMowingDaysPotential)
              global mowingDayPotential[nMowingDaysPotential] = aDay
#              println("Mowing days: ",mowingDayPotential)
            end
          else
#            println("MowingDays: ",mowingDayPotential)
#            exit(0)
            for i in 1:nMowingDaysPotential
              if mowingDayPotential[i] == aDay
                global mowingRequired = true
                break
              end
            end
          end

          if mowingRequired
            global lastDayMowedPotential = aDay
            global mowed = cropYield[aDay].potential.total.living + cropYield[aDay].potential.total.dead - 700.0
            if mowed < 2000.0
              global delayInPotentialRegrowth = 2
            else
              if mowed < 4000.0
                global delayInPotentialRegrowth = 3
              else
                global delayInPotentialRegrowth = 4
              end
            end

            global cropYield[aDay].dailyPotentialGrowth.total.living = 0.0
            global cropYield[aDay].dailyPotentialGrowth.total.dead = 0.0
            global cropYield[aDay].potential.total.living = 700.0
            global cropYield[aDay].potential.total.dead = 0.0
            global cropYield[aDay].dailyPotentialGrowth.mowed = mowed

            fl = interpolate(GrowthPartToLeavesDaynumber, t)
            fs = interpolate(GrowthPartToStemsDaynumber, t)

            global cropYield[aDay].potential.leaves.living = fl * 700.0
            global cropYield[aDay].potential.stem.living = fs * 700.0
            global cropYield[aDay].potential.leaves.dead = fl * 0.0
            global cropYield[aDay].potential.stem.dead = fs * 0.0
          end
        end

        global cropYield[aDay].potential.rootingDepth = interpolate(RootDepthRootWeight,cropYield[aDay].potential.roots.living + cropYield[aDay].potential.roots.dead)
        global cropYield[aDay].potential.lai = cropYield[aDay].potential.leaves.living * interpolate(SpecificLeafAreaDaynumber, 0.0)
        global cropYield[aDay].potential.mowed = cropYield[aDay-1].potential.mowed + mowed
#       println(aDay,"   ",cropYield[aDay].potential.total.living,"   ",cropYield[aDay].potential.mowed)
      catch e
        println("???ERROR in Grass.potentialGrassGrowth: ",e)
      end
    finally
    end
  end

  function actualGrassGrowth(aMeteo :: Main.Control.Types.Meteo, aDay :: Int64, aMoisture :: Float64, aTemperature :: Float64)
    try
      try
        fMoisture = aMoisture
        fTemperature = aTemperature
        mowed = 0.0

        if aDay <= lastDayMowedActual + delayInActualRegrowth
          copyActualValues(aDay)
        else
          t =convert(Float64, aDay)
          avrad = 1000.0 * aMeteo.radiation
          scv = 0.2

#         Declination and solar constant for this day
          declination = -asin(sind(23.45) * cos(2.0 * pi * (t+10) /365.0))
          solarConstant  = 1370.0 * (1.0 + 0.033 * cos(2.0*pi*t/365.0))

#         calculation of daylength from intermediate variables
#         SINLD, COSLD and AOB
          sinld = sind(latitude)*sin(declination)
          cosld = cosd(latitude)*cos(declination)
          aob = sinld/cosld

#         Calculate solution for base=0 degrees
          if abs(aob) <= 1.0
            daylength = 12.0 * (1.0 + 2.0 * asin(aob) / pi)
#           integrals of sine of solar height
            dsinb  = 3600.0 * (daylength * sinld + 24.0 * cosld * sqrt(1.0-aob*aob)/pi)
            dsinbe = 3600.0 * (daylength * (sinld + 0.40 * (sinld* sinld + cosld * cosld * 0.5)) + 12.0 * cosld * (2.0 + 3.0 * 0.4 * sinld) * sqrt(1.0 - aob * aob)/pi)
          else
            if aob > 1.0
              daylength = 24.0
            end
            if aob < 1.0
              daylength =  0.0
            end
#           integrals of sine of solar height
            dsinb  = 3600.0 * (daylength * sinld)
            dsinbe = 3600.0 * (daylength * (sinld + 0.4 * (sinld * sinld + cosld * cosld * 0.5)))
          end

#         Calculate solution for base =-4 (ANGLE) degrees
          angle = -4.0
          aob_corr = (-sind(angle) + sinld)/cosld
          if abs(aob_corr) <= 1.0
            daylp = 12.0 * (1.0 + 2.0 * asin(aob_corr) / pi)
          else
            if aob_corr > 1.0
              daylp = 24.0
            end
            if aob_corr < -1.0
              daylp =  0.0
            end
          end

#         extraterrestrial radiation and atmospheric transmission
          angot  = solarConstant * dsinb
#         Check for daylength=0 as in that case the angot radiation is 0 as well
          atmtr = 0.0
          if daylength > 0.0
            atmtr = avrad / angot
          end

#         estimate fraction diffuse irradiation
          frdif = 0.0
          if atmtr > 0.75
            frdif = 0.23
          end
          if atmtr < 0.75 && atmtr > 0.35
            frdif = 1.33 - 1.46 * atmtr
          end
          if atmtr <= 0.35 && atmtr > 0.07
            frdif = 1.0 - 2.3 * (atmtr - 0.07) * (atmtr - 0.07)
          end
          if atmtr <= 0.07
            frdif = 1.0
          end
          difpp = frdif * atmtr * 0.5 * solarConstant

          amax = interpolate(AssimilationRateDayNumber,t) * interpolate(AmaxReductionAverageAirTemp, aMeteo.aveTemp)

#         actual growth

#          cropYield[aDay-1].actual.lai = 5.0
          dtga  = 0.0
          if amax > 0.0 && cropYield[aDay-1].actual.lai > 0.0
            for i in 1:3
              hour = 12.0 + daylength * (Gauss3x[i] - 0.5)
              sinb = max(0.0, sinld + cosld *cos(2.0 * pi * (hour + 12.0) / 24.0))
              par = 0.5 * avrad * sinb * (1.0 + 0.4 * sinb) / dsinbe
              pardif = min(par, sinb * difpp)
              pardir = par - pardif

#             extinction coefficients KDIF,KDIRBL,KDIRT, start of assim
              refh   = (1.0 - sqrt(1.0 - scv)) / (1.0 + sqrt(1.0 - scv))
              refs   = refh * 2.0 / (1.0 + 1.6 * sinb)
              kdirbl = (0.5 / sinb) * kdif / (0.8 * sqrt(1.0 - scv))
              kdirt  = kdirbl * sqrt(1.0 - scv)

#             three-point Gaussian integration over LAI
              fgros  = 0.0
              for j in 1:3
                laic   = cropYield[aDay-1].actual.lai * Gauss3x[j]
#               absorbed diffuse radiation (VISDF),light from direct
#               origine (VIST) and direct light(VISD)
                visdf  = (1.0 - refs) * pardif * kdif * exp(-kdif * laic)
                vist   = (1.0 - refs) * pardir * kdirt * exp(-kdirt * laic)
                visd   = (1.0 - scv) * pardir * kdirbl * exp(-kdirbl*laic)
#               absorbed flux in W/m2 for shaded leaves and assimilation
                visshd = visdf + vist - visd
                fgrsh  = amax * (1.0 - exp(-visshd * eff / max(2.0,amax)))
#               direct light absorbed by leaves perpendicular on direct
#               beam and assimilation of sunlit leaf area
                vispp  = (1.0 - scv) * pardir / sinb
                fgrsun = fgrsh
                if vispp > 0.0
                  fgrsun = amax * (1.0 - (amax - fgrsh) * (1.0-exp(-vispp * eff / max(2.0,amax))) / (eff * vispp))
                end
#               fraction of sunlit leaf area (FSLLA) and local assimilation rate (FGL)
                fslla  = exp(-kdirbl * laic)
                fgl    = fslla * fgrsun + (1.0 - fslla) * fgrsh
#               integration
                fgros  += fgl * Gauss3w[j]
              end
              fgros  *=  cropYield[aDay-1].actual.lai
#             end of assim
              dtga += fgros * Gauss3w[i]
            end
            dtga = dtga * daylength
          end

#          println(dtga)
#          exit(0)

#         correction for low minimum temperature
          dtga *= interpolate(AmaxReductionMinAirTemp, aMeteo.minTemp)
#         actual assimilation in kg ch2o per ha
          pgass = dtga * 30.0 / 44.0

#         water stress reduction of pgass to gass and limited attainable maximum
          gass = pgass * fMoisture * fTemperature

#         relative management factor that reduces crop growth
          gass = gass * relmf

#         respiration and partitioning of carbohydrates between growth and maintenance respiration
          rmres = (rmr * cropYield[aDay-1].actual.roots.living +
                    rml * cropYield[aDay-1].actual.leaves.living +
                    rms * cropYield[aDay-1].actual.stem.living) *
                    interpolate(SenescenceReductionDaynumber,t)
          teff = q10^((aMeteo.aveTemp - 25.0) / 10.0)
          mres = min(gass, rmres * teff)
          asrc = gass - mres
#         println(t,"   ",asrc,"   ",gass,"   ",mres,"    ",rmres,"    ",teff)

#         partitioning factors
          fr = interpolate(GrowthPartToRootsDaynumber, t)
          fl = interpolate(GrowthPartToLeavesDaynumber, t)
          fs = interpolate(GrowthPartToStemsDaynumber, t)
#         check on partitioning
          fcheck = fr + (fl + fs) * (1.0 - fr) - 1.0
          if abs(fcheck) > 0.0001
            println("???ERROR in partitioning: sum=",fcheck)
          end

#         dry matter increase
          cvf = 1.0 / ((fl / cvl + fs / cvs) * (1.0 - fr) +fr / cvr)
          dmi = cvf * asrc
#          println(dmi)
#         check on carbon balance
          ccheck = (gass - mres - (fr + (fl + fs) * (1.0 - fr)) * dmi / cvf) / max(0.0001,gass)
          if abs(ccheck) > 0.0001
            println("???ERROR: The carbon balance is not correct")
          end

#         growth rate by plant organ

#         growth rate roots and aerial parts
#         after reaching a live weight of wrtmax(default 2500 kg), the
#         growth of the roots is balanced by the death of root tissue
          deathRateOfRoots = cropYield[aDay-1].actual.roots.living * fTemperature * interpolate(RelativeDeathRateOfRootsDaynumber,t)
          growthRateOfRoots = fr * dmi
          newWeight = cropYield[aDay-1].actual.roots.living + growthRateOfRoots - deathRateOfRoots
          if newWeight > maximumRootWeight
            growthRateOfRoots = max(0.0, growthRateOfRoots  - (newWeight - maximumRootWeight))
            deathRateOfRoots = max(0.0, cropYield[aDay-1].actual.roots.living + growthRateOfRoots - maximumRootWeight)
          end
#          println("gr=", growthRateOfRoots,"   dr=", deathRateOfRoots, "  living=", cropYield[aDay-1].actual.roots.living, "  dead=",cropYield[aDay-1].actual.roots.dead)

#         growth rate leaves
#         weight of new leaves
          admi = (1.0 - fr) * dmi
          growthRateLeaves = fl * admi

#         death of leaves due to water stress, temperature or high lai
          dslv1 = growthRateLeaves * fTemperature * (1.0 - fMoisture) * RelativeDeathRateOfLeavesByWaterStress
          laicr = 3.2/kdif
          dslv2 = cropYield[aDay-1].actual.leaves.living * max(0.0, min(0.03,0.03 * (cropYield[aDay-1].actual.lai - laicr) / laicr))
          deathRateLeavesLai = max(dslv1, dslv2)

#         death of leaves due to exceeding life span;
#         leaf death is imposed on array until no more leaves have
#         to die or all leaves are gone

          deathRateLeavesAge = 0.0
          fysdel = max(0.0, (aMeteo.aveTemp - thresholdTempLeafAgeing)/(35.0 - thresholdTempLeafAgeing))
          for i in lastDayMowedActual + 1 : aDay-1
            cropYield[i].actual.leaveAge += fysdel
#            if aDay > 160 && aDay < 170
#              println(aDay,"  ",i, "   ",fysdel,"  ",maxAgeOfLeaves,"   ",cropYield[i].actual.leaveAge)
#            end
            if cropYield[i].actual.leaveAge > maxAgeOfLeaves && cropYield[i].actual.leaves.living > 0.0
              if cropYield[i].dailyActualGrowth.leaves.living > 0.0
                deathRateLeavesAge += cropYield[i].dailyActualGrowth.leaves.living
                global cropYield[i].dailyActualGrowth.leaves.dead += cropYield[i].dailyActualGrowth.leaves.living
                global cropYield[i].dailyActualGrowth.leaves.living = 0.0
              end
            end
          end

#         leaf area not to exceed exponential growth curve
          glaiexp = 0.0
          slatpot = interpolate(SpecificLeafAreaDaynumber, t)
          if cropYield[aDay-1].actual.laiExp < 6.0
            dteff = max(0.0, aMeteo.aveTemp - thresholdTempLeafAgeing)
            glaiexp = cropYield[aDay-1].actual.laiExp * dteff * rgrlai
            glasol = growthRateLeaves * slatpot
            gla = min(glaiexp,glasol)
#           adjustment of specific leaf area of youngest leaf class
            if growthRateLeaves > 0.0
              slat = gla/growthRateLeaves
            end
          end

#       lai in case of exponential growthRateStem
        global cropYield[aDay].actual.laiExp += glaiexp

#         growth rate stems
          wst = cropYield[aDay-1].actual.stem.living
          growthRateStem = fs*admi
#         death of stems due to water stress is zero in case of actual growth
          deathRateStem1 = growthRateStem * fTemperature * (1.0 - fMoisture) * RelativeDeathRateOfLeavesByWaterStress
#         death of stems due to ageing
          deathRateStem2 = interpolate(RelativeDeathRateOfStemsDaynumber, t) * wst
          deathRateStem = deathRateStem1 + deathRateStem2
#          if aDay > 160 && aDay < 170
#            println(aDay,"   ",cropYield[aDay-1].actual.leaves.living, "   ", growthRateLeaves,   "   ", deathRateLeavesLai, "   ", deathRateLeavesAge)
#          end
#         integrals of the crop
#         dry weight of living plant organs
          global cropYield[aDay].dailyActualGrowth.leaves.living = growthRateLeaves - deathRateLeavesLai
          global cropYield[aDay].actual.leaves.living = max(0.0, cropYield[aDay-1].actual.leaves.living + growthRateLeaves - deathRateLeavesLai - deathRateLeavesAge)
          global cropYield[aDay].dailyActualGrowth.roots.living = growthRateOfRoots
          global cropYield[aDay].actual.roots.living = cropYield[aDay-1].actual.roots.living + growthRateOfRoots - deathRateOfRoots
          global cropYield[aDay].dailyActualGrowth.stem.living = growthRateStem - deathRateStem
          global cropYield[aDay].actual.stem.living = cropYield[aDay-1].actual.stem.living + growthRateStem - deathRateStem

#         dry weight of dead plant organs (roots,leaves & stems)
          global cropYield[aDay].dailyActualGrowth.roots.dead =  deathRateOfRoots
          global cropYield[aDay].actual.roots.dead = cropYield[aDay-1].actual.roots.dead + deathRateOfRoots
          global cropYield[aDay].actual.leaves.dead = cropYield[aDay-1].actual.leaves.dead + deathRateLeavesLai + deathRateLeavesAge
          global cropYield[aDay].dailyActualGrowth.stem.dead = deathRateStem
          global cropYield[aDay].actual.stem.dead = cropYield[aDay-1].actual.stem.dead + deathRateStem

#         total
          global cropYield[aDay].actual.total.living = cropYield[aDay].actual.leaves.living + cropYield[aDay].actual.stem.living
          global cropYield[aDay].actual.total.dead = cropYield[aDay].actual.leaves.dead + cropYield[aDay].actual.stem.dead

#         mowing
          mowingRequired = false
          if gettingMowingDaysActual
            if (cropYield[aDay].actual.total.living + cropYield[aDay].actual.total.dead > tresholdForMowing && aDay < lastAllowedMowingDay) ||
               (aDay == lastAllowedMowingDay && cropYield[aDay].actual.total.living + cropYield[aDay].actual.total.dead >= tresholdForLastMowing)
              global mowingRequired = true
              global nMowingDaysActual += 1
              resize!(mowingDayActual, nMowingDaysActual)
              global mowingDayActual[nMowingDaysActual] = aDay
            end
          else
            for i in 1:nMowingDaysActual
              if mowingDayActual[i] == aDay
                global mowingRequired = true
                break
              end
            end
          end

          if mowingRequired
            global lastDayMowedActual = aDay
            global mowed = cropYield[aDay].actual.total.living + cropYield[aDay].actual.total.dead- 700.0
            if mowed < 2000.0
              global delayInActualRegrowth = 2
            else
              if mowed < 4000.0
                global delayInActualRegrowth = 3
              else
                global delayInActualRegrowth = 4
              end
            end

            global cropYield[aDay].dailyActualGrowth.total.living = 0.0
            global cropYield[aDay].dailyActualGrowth.total.dead = 0.0
            global cropYield[aDay].actual.total.living = 700.0
            global cropYield[aDay].actual.total.dead = 0.0

            global cropYield[aDay].dailyActualGrowth.mowed = mowed

            fl = interpolate(GrowthPartToLeavesDaynumber, t)
            fs = interpolate(GrowthPartToStemsDaynumber, t)

            global cropYield[aDay].actual.leaves.living = fl * 700.0
            global cropYield[aDay].actual.stem.living = fs * 700.0
            global cropYield[aDay].actual.leaves.dead = fl * 0.0
            global cropYield[aDay].actual.stem.dead = fs * 0.0
          end
        end

        global cropYield[aDay].actual.rootingDepth = interpolate(RootDepthRootWeight,cropYield[aDay].actual.roots.living + cropYield[aDay].actual.roots.dead)
        global cropYield[aDay].actual.lai = cropYield[aDay].actual.leaves.living * interpolate(SpecificLeafAreaDaynumber, 0.0)
        global cropYield[aDay].actual.mowed = cropYield[aDay-1].actual.mowed + mowed
#       println(aDay,"   ",cropYield[aDay].actual.total.living,"   ",cropYield[aDay].actual.mowed)
      catch e
        println("???ERROR in Grass.actualGrassGrowth: ",e)
      end
    finally
    end
  end

  function moistureGrassGrowth(aMeteo :: Main.Control.Types.Meteo, aDay :: Int64, aMoisture :: Float64)
    try
      try
        fMoisture = aMoisture
        fTemperature = 1.0
        mowed = 0.0
        if aDay <= lastDayMowedMoisture + delayInMoistureRegrowth
          copyMoistureValues(aDay)
        else
          t =convert(Float64, aDay)
          avrad = 1000.0 * aMeteo.radiation
          scv = 0.2

#         Declination and solar constant for this day
          declination = -asin(sind(23.45) * cos(2.0 * pi * (t+10) /365.0))
          solarConstant  = 1370.0 * (1.0 + 0.033 * cos(2.0*pi*t/365.0))

#         calculation of daylength from intermediate variables
#         SINLD, COSLD and AOB
          sinld = sind(latitude)*sin(declination)
          cosld = cosd(latitude)*cos(declination)
          aob = sinld/cosld

#         Calculate solution for base=0 degrees
          if abs(aob) <= 1.0
            daylength = 12.0 * (1.0 + 2.0 * asin(aob) / pi)
#           integrals of sine of solar height
            dsinb  = 3600.0 * (daylength * sinld + 24.0 * cosld * sqrt(1.0-aob*aob)/pi)
            dsinbe = 3600.0 * (daylength * (sinld + 0.40 * (sinld* sinld + cosld * cosld * 0.5)) + 12.0 * cosld * (2.0 + 3.0 * 0.4 * sinld) * sqrt(1.0 - aob * aob)/pi)
          else
            if aob > 1.0
              daylength = 24.0
            end
            if aob < 1.0
              daylength =  0.0
            end
#           integrals of sine of solar height
            dsinb  = 3600.0 * (daylength * sinld)
            dsinbe = 3600.0 * (daylength * (sinld + 0.4 * (sinld * sinld + cosld * cosld * 0.5)))
          end

#         Calculate solution for base =-4 (ANGLE) degrees
          angle = -4.0
          aob_corr = (-sind(angle) + sinld)/cosld
          if abs(aob_corr) <= 1.0
            daylp = 12.0 * (1.0 + 2.0 * asin(aob_corr) / pi)
          else
            if aob_corr > 1.0
              daylp = 24.0
            end
            if aob_corr < -1.0
              daylp =  0.0
            end
          end

#         extraterrestrial radiation and atmospheric transmission
          angot  = solarConstant * dsinb
#         Check for daylength=0 as in that case the angot radiation is 0 as well
          atmtr = 0.0
          if daylength > 0.0
            atmtr = avrad / angot
          end

#         estimate fraction diffuse irradiation
          frdif = 0.0
          if atmtr > 0.75
            frdif = 0.23
          end
          if atmtr < 0.75 && atmtr > 0.35
            frdif = 1.33 - 1.46 * atmtr
          end
          if atmtr <= 0.35 && atmtr > 0.07
            frdif = 1.0 - 2.3 * (atmtr - 0.07) * (atmtr - 0.07)
          end
          if atmtr <= 0.07
            frdif = 1.0
          end
          difpp = frdif * atmtr * 0.5 * solarConstant

          amax = interpolate(AssimilationRateDayNumber,t) * interpolate(AmaxReductionAverageAirTemp, aMeteo.aveTemp)

#         actual growth

#          cropYield[aDay-1].moisture.lai = 5.0
          dtga  = 0.0
          if amax > 0.0 && cropYield[aDay-1].moisture.lai > 0.0
            for i in 1:3
              hour = 12.0 + daylength * (Gauss3x[i] - 0.5)
              sinb = max(0.0, sinld + cosld *cos(2.0 * pi * (hour + 12.0) / 24.0))
              par = 0.5 * avrad * sinb * (1.0 + 0.4 * sinb) / dsinbe
              pardif = min(par, sinb * difpp)
              pardir = par - pardif

#             extinction coefficients KDIF,KDIRBL,KDIRT, start of assim
              refh   = (1.0 - sqrt(1.0 - scv)) / (1.0 + sqrt(1.0 - scv))
              refs   = refh * 2.0 / (1.0 + 1.6 * sinb)
              kdirbl = (0.5 / sinb) * kdif / (0.8 * sqrt(1.0 - scv))
              kdirt  = kdirbl * sqrt(1.0 - scv)

#             three-point Gaussian integration over LAI
              fgros  = 0.0
              for j in 1:3
                laic   = cropYield[aDay-1].moisture.lai * Gauss3x[j]
#               absorbed diffuse radiation (VISDF),light from direct
#               origine (VIST) and direct light(VISD)
                visdf  = (1.0 - refs) * pardif * kdif * exp(-kdif * laic)
                vist   = (1.0 - refs) * pardir * kdirt * exp(-kdirt * laic)
                visd   = (1.0 - scv) * pardir * kdirbl * exp(-kdirbl*laic)
#               absorbed flux in W/m2 for shaded leaves and assimilation
                visshd = visdf + vist - visd
                fgrsh  = amax * (1.0 - exp(-visshd * eff / max(2.0,amax)))
#               direct light absorbed by leaves perpendicular on direct
#               beam and assimilation of sunlit leaf area
                vispp  = (1.0 - scv) * pardir / sinb
                fgrsun = fgrsh
                if vispp > 0.0
                  fgrsun = amax * (1.0 - (amax - fgrsh) * (1.0-exp(-vispp * eff / max(2.0,amax))) / (eff * vispp))
                end
#               fraction of sunlit leaf area (FSLLA) and local assimilation rate (FGL)
                fslla  = exp(-kdirbl * laic)
                fgl    = fslla * fgrsun + (1.0 - fslla) * fgrsh
#               integration
                fgros  += fgl * Gauss3w[j]
              end
              fgros  *=  cropYield[aDay-1].moisture.lai
#             end of assim
              dtga += fgros * Gauss3w[i]
            end
            dtga = dtga * daylength
          end

#          println(dtga)
#          exit(0)

#         correction for low minimum temperature
          dtga *= interpolate(AmaxReductionMinAirTemp, aMeteo.minTemp)
#         actual assimilation in kg ch2o per ha
          pgass = dtga * 30.0 / 44.0

#         water stress reduction of pgass to gass and limited attainable maximum
          gass = pgass * fTemperature * fMoisture

#         relative management factor that reduces crop growth
          gass = gass * relmf

#         respiration and partitioning of carbohydrates between growth and maintenance respiration
          rmres = (rmr * cropYield[aDay-1].moisture.roots.living +
                    rml * cropYield[aDay-1].moisture.leaves.living +
                    rms * cropYield[aDay-1].moisture.stem.living) *
                    interpolate(SenescenceReductionDaynumber,t)
          teff = q10^((aMeteo.aveTemp - 25.0) / 10.0)
          mres = min(gass, rmres * teff)
          asrc = gass - mres
#         println(t,"   ",asrc,"   ",gass,"   ",mres,"    ",rmres,"    ",teff)

#         partitioning factors
          fr = interpolate(GrowthPartToRootsDaynumber, t)
          fl = interpolate(GrowthPartToLeavesDaynumber, t)
          fs = interpolate(GrowthPartToStemsDaynumber, t)
#         check on partitioning
          fcheck = fr + (fl + fs) * (1.0 - fr) - 1.0
          if abs(fcheck) > 0.0001
            println("???ERROR in partitioning: sum=",fcheck)
          end

#         dry matter increase
          cvf = 1.0 / ((fl / cvl + fs / cvs) * (1.0 - fr) +fr / cvr)
          dmi = cvf * asrc
#          println(dmi)
#         check on carbon balance
          ccheck = (gass - mres - (fr + (fl + fs) * (1.0 - fr)) * dmi / cvf) / max(0.0001,gass)
          if abs(ccheck) > 0.0001
            println("???ERROR: The carbon balance is not correct")
          end

#         growth rate by plant organ

#         growth rate roots and aerial parts
#         after reaching a live weight of wrtmax(default 2500 kg), the
#         growth of the roots is balanced by the death of root tissue
          deathRateOfRoots = fTemperature * cropYield[aDay-1].moisture.roots.living * interpolate(RelativeDeathRateOfRootsDaynumber,t)
          growthRateOfRoots = fr * dmi
          newWeight = cropYield[aDay-1].moisture.roots.living + growthRateOfRoots - deathRateOfRoots
          if newWeight > maximumRootWeight
            growthRateOfRoots = max(0.0, growthRateOfRoots  - (newWeight - maximumRootWeight))
            deathRateOfRoots = max(0.0, cropYield[aDay-1].moisture.roots.living + growthRateOfRoots - maximumRootWeight)
          end
#          println("gr=", growthRateOfRoots,"   dr=", deathRateOfRoots, "  living=", cropYield[aDay-1].moisture.roots.living, "  dead=",cropYield[aDay-1].moisture.roots.dead)

#         growth rate leaves
#         weight of new leaves
          admi = (1.0 - fr) * dmi
          growthRateLeaves = fl * admi

#         death of leaves due to water stress or high lai
          dslv1 = growthRateLeaves * fTemperature * (1.0 - fMoisture) * RelativeDeathRateOfLeavesByWaterStress
          laicr = 3.2/kdif
          dslv2 = cropYield[aDay-1].moisture.leaves.living * max(0.0, min(0.03,0.03 * (cropYield[aDay-1].moisture.lai - laicr) / laicr))
          deathRateLeavesLai = max(dslv1, dslv2)

#         death of leaves due to exceeding life span;
#         leaf death is imposed on array until no more leaves have
#         to die or all leaves are gone

          deathRateLeavesAge = 0.0
          fysdel = max(0.0, (aMeteo.aveTemp - thresholdTempLeafAgeing)/(35.0 - thresholdTempLeafAgeing))
          for i in lastDayMowedMoisture + 1 : aDay-1
            cropYield[i].moisture.leaveAge += fysdel
            if cropYield[i].moisture.leaveAge > maxAgeOfLeaves && cropYield[i].moisture.leaves.living > 0.0
              if cropYield[i].dailyMoistureGrowth.leaves.living > 0.0
                deathRateLeavesAge += cropYield[i].dailyMoistureGrowth.leaves.living
                global cropYield[i].dailyMoistureGrowth.leaves.dead += cropYield[i].dailyMoistureGrowth.leaves.living
                global cropYield[i].dailyMoistureGrowth.leaves.living = 0.0
              end
            end
          end

#         leaf area not to exceed exponential growth curve
          glaiexp = 0.0
          slatpot = interpolate(SpecificLeafAreaDaynumber, t)
          if cropYield[aDay-1].moisture.laiExp < 6.0
            dteff = max(0.0, aMeteo.aveTemp - thresholdTempLeafAgeing)
            glaiexp = cropYield[aDay-1].moisture.laiExp * dteff * rgrlai
            glasol = growthRateLeaves * slatpot
            gla = min(glaiexp,glasol)
#           adjustment of specific leaf area of youngest leaf class
            if growthRateLeaves > 0.0
              slat = gla/growthRateLeaves
            end
          end

#         lai in case of exponential growthRateStem
          global cropYield[aDay].moisture.laiExp += glaiexp

#         growth rate stems
          wst = cropYield[aDay-1].moisture.stem.living
          growthRateStem = fs*admi
#         death of stems due to water stress is zero in case of actual growth
          deathRateStem1 = growthRateStem * fTemperature * (1.0 - fMoisture) * RelativeDeathRateOfLeavesByWaterStress
#         death of stems due to ageing
          deathRateStem2 = interpolate(RelativeDeathRateOfStemsDaynumber, t) * wst
          deathRateStem = deathRateStem1 + deathRateStem2

#         integrals of the crop
#         dry weight of living plant organs
          global cropYield[aDay].dailyMoistureGrowth.leaves.living = growthRateLeaves - deathRateLeavesLai
          global cropYield[aDay].moisture.leaves.living = max(0.0, cropYield[aDay-1].moisture.leaves.living + growthRateLeaves - deathRateLeavesLai - deathRateLeavesAge)
          global cropYield[aDay].dailyMoistureGrowth.roots.living = growthRateOfRoots
          global cropYield[aDay].moisture.roots.living = cropYield[aDay-1].moisture.roots.living + growthRateOfRoots - deathRateOfRoots
          global cropYield[aDay].dailyMoistureGrowth.stem.living = growthRateStem - deathRateStem
          global cropYield[aDay].moisture.stem.living = cropYield[aDay-1].moisture.stem.living + growthRateStem - deathRateStem

#         dry weight of dead plant organs (roots,leaves & stems)
          global cropYield[aDay].dailyMoistureGrowth.roots.dead =  deathRateOfRoots
          global cropYield[aDay].moisture.roots.dead = cropYield[aDay-1].moisture.roots.dead + deathRateOfRoots
          global cropYield[aDay].moisture.leaves.dead = cropYield[aDay-1].moisture.leaves.dead + deathRateLeavesLai + deathRateLeavesAge
          global cropYield[aDay].dailyMoistureGrowth.stem.dead = deathRateStem
          global cropYield[aDay].moisture.stem.dead = cropYield[aDay-1].moisture.stem.dead + deathRateStem

#         total
          global cropYield[aDay].moisture.total.living = cropYield[aDay].moisture.leaves.living + cropYield[aDay].moisture.stem.living
          global cropYield[aDay].moisture.total.dead = cropYield[aDay].moisture.leaves.dead + cropYield[aDay].moisture.stem.dead

#         mowing
          mowingRequired = false
          if gettingMowingDaysMoisture
            if (cropYield[aDay].moisture.total.living + cropYield[aDay].moisture.total.dead > tresholdForMowing && aDay < lastAllowedMowingDay) ||
               (aDay == lastAllowedMowingDay && cropYield[aDay].moisture.total.living + cropYield[aDay].moisture.total.dead >= tresholdForLastMowing)
              global mowingRequired = true
              global nMowingDaysMoisture += 1
              resize!(mowingDayMoisture, nMowingDaysMoisture)
              global mowingDayMoisture[nMowingDaysMoisture] = aDay
            end
          else
            for i in 1:nMowingDaysMoisture
              if mowingDayMoisture[i] == aDay
                global mowingRequired = true
                break
              end
            end
          end

          if mowingRequired
            global lastDayMowedMoisture = aDay
            global mowed = cropYield[aDay].moisture.total.living + cropYield[aDay].moisture.total.dead - 700.0
            if mowed < 2000.0
              global delayInMoistureRegrowth = 2
            else
              if mowed < 4000.0
                global delayInMoistureRegrowth = 3
              else
                global delayInMoistureRegrowth = 4
              end
            end

            global cropYield[aDay].dailyMoistureGrowth.total.living = 0.0
            global cropYield[aDay].dailyMoistureGrowth.total.dead = 0.0
            global cropYield[aDay].moisture.total.living = 700.0
            global cropYield[aDay].moisture.total.dead = 0.0

            global cropYield[aDay].dailyMoistureGrowth.mowed = mowed

            fl = interpolate(GrowthPartToLeavesDaynumber, t)
            fs = interpolate(GrowthPartToStemsDaynumber, t)

            global cropYield[aDay].moisture.leaves.living = fl * 700.0
            global cropYield[aDay].moisture.stem.living = fs * 700.0
            global cropYield[aDay].moisture.leaves.dead = fl * 0.0
            global cropYield[aDay].moisture.stem.dead = fs * 0.0
          end
        end

        global cropYield[aDay].moisture.rootingDepth = interpolate(RootDepthRootWeight,cropYield[aDay].moisture.roots.living + cropYield[aDay].moisture.roots.dead)
        global cropYield[aDay].moisture.lai = cropYield[aDay].moisture.leaves.living * interpolate(SpecificLeafAreaDaynumber, 0.0)
        global cropYield[aDay].moisture.mowed = cropYield[aDay-1].moisture.mowed + mowed
#        println(aDay,"   ",cropYield[aDay].moisture.total.living,"   ",cropYield[aDay].moisture.mowed)
      catch e
        println("???ERROR in Grass.moistureGrassGrowth: ",e)
      end
    finally
    end
  end

  function temperatureGrassGrowth(aMeteo :: Main.Control.Types.Meteo, aDay :: Int64, aTemperature :: Float64)
    try
      try
        fMoisture = 1.0
        fTemperature = aTemperature
        mowed = 0.0

        if aDay <= lastDayMowedTemperature + delayInTemperatureRegrowth
          copyTemperatureValues(aDay)
        else
          t =convert(Float64, aDay)
          avrad = 1000.0 * aMeteo.radiation
          scv = 0.2

#         Declination and solar constant for this day
          declination = -asin(sind(23.45) * cos(2.0 * pi * (t+10) /365.0))
          solarConstant  = 1370.0 * (1.0 + 0.033 * cos(2.0*pi*t/365.0))

#         calculation of daylength from intermediate variables
#         SINLD, COSLD and AOB
          sinld = sind(latitude)*sin(declination)
          cosld = cosd(latitude)*cos(declination)
          aob = sinld/cosld

#         Calculate solution for base=0 degrees
          if abs(aob) <= 1.0
            daylength = 12.0 * (1.0 + 2.0 * asin(aob) / pi)
#           integrals of sine of solar height
            dsinb  = 3600.0 * (daylength * sinld + 24.0 * cosld * sqrt(1.0-aob*aob)/pi)
            dsinbe = 3600.0 * (daylength * (sinld + 0.40 * (sinld* sinld + cosld * cosld * 0.5)) + 12.0 * cosld * (2.0 + 3.0 * 0.4 * sinld) * sqrt(1.0 - aob * aob)/pi)
          else
            if aob > 1.0
              daylength = 24.0
            end
            if aob < 1.0
              daylength =  0.0
            end
#           integrals of sine of solar height
            dsinb  = 3600.0 * (daylength * sinld)
            dsinbe = 3600.0 * (daylength * (sinld + 0.4 * (sinld * sinld + cosld * cosld * 0.5)))
          end

#         Calculate solution for base =-4 (ANGLE) degrees
          angle = -4.0
          aob_corr = (-sind(angle) + sinld)/cosld
          if abs(aob_corr) <= 1.0
            daylp = 12.0 * (1.0 + 2.0 * asin(aob_corr) / pi)
          else
            if aob_corr > 1.0
              daylp = 24.0
            end
            if aob_corr < -1.0
              daylp =  0.0
            end
          end

#         extraterrestrial radiation and atmospheric transmission
          angot  = solarConstant * dsinb
#         Check for daylength=0 as in that case the angot radiation is 0 as well
          atmtr = 0.0
          if daylength > 0.0
            atmtr = avrad / angot
          end

#         estimate fraction diffuse irradiation
          frdif = 0.0
          if atmtr > 0.75
            frdif = 0.23
          end
          if atmtr < 0.75 && atmtr > 0.35
            frdif = 1.33 - 1.46 * atmtr
          end
          if atmtr <= 0.35 && atmtr > 0.07
            frdif = 1.0 - 2.3 * (atmtr - 0.07) * (atmtr - 0.07)
          end
          if atmtr <= 0.07
            frdif = 1.0
          end
          difpp = frdif * atmtr * 0.5 * solarConstant

          amax = interpolate(AssimilationRateDayNumber,t) * interpolate(AmaxReductionAverageAirTemp, aMeteo.aveTemp)

#         actual growth

          dtga  = 0.0
          if amax > 0.0 && cropYield[aDay-1].temperature.lai > 0.0
            for i in 1:3
              hour = 12.0 + daylength * (Gauss3x[i] - 0.5)
              sinb = max(0.0, sinld + cosld *cos(2.0 * pi * (hour + 12.0) / 24.0))
              par = 0.5 * avrad * sinb * (1.0 + 0.4 * sinb) / dsinbe
              pardif = min(par, sinb * difpp)
              pardir = par - pardif

#             extinction coefficients KDIF,KDIRBL,KDIRT, start of assim
              refh   = (1.0 - sqrt(1.0 - scv)) / (1.0 + sqrt(1.0 - scv))
              refs   = refh * 2.0 / (1.0 + 1.6 * sinb)
              kdirbl = (0.5 / sinb) * kdif / (0.8 * sqrt(1.0 - scv))
              kdirt  = kdirbl * sqrt(1.0 - scv)

#             three-point Gaussian integration over LAI
              fgros  = 0.0
              for j in 1:3
                laic   = cropYield[aDay-1].temperature.lai * Gauss3x[j]
#               absorbed diffuse radiation (VISDF),light from direct
#               origine (VIST) and direct light(VISD)
                visdf  = (1.0 - refs) * pardif * kdif * exp(-kdif * laic)
                vist   = (1.0 - refs) * pardir * kdirt * exp(-kdirt * laic)
                visd   = (1.0 - scv) * pardir * kdirbl * exp(-kdirbl*laic)
#               absorbed flux in W/m2 for shaded leaves and assimilation
                visshd = visdf + vist - visd
                fgrsh  = amax * (1.0 - exp(-visshd * eff / max(2.0,amax)))
#               direct light absorbed by leaves perpendicular on direct
#               beam and assimilation of sunlit leaf area
                vispp  = (1.0 - scv) * pardir / sinb
                fgrsun = fgrsh
                if vispp > 0.0
                  fgrsun = amax * (1.0 - (amax - fgrsh) * (1.0-exp(-vispp * eff / max(2.0,amax))) / (eff * vispp))
                end
#               fraction of sunlit leaf area (FSLLA) and local assimilation rate (FGL)
                fslla  = exp(-kdirbl * laic)
                fgl    = fslla * fgrsun + (1.0 - fslla) * fgrsh
#               integration
                fgros  += fgl * Gauss3w[j]
              end
              fgros  *=  cropYield[aDay-1].temperature.lai
#             end of assim
              dtga += fgros * Gauss3w[i]
            end
            dtga = dtga * daylength
          end

#          println(dtga)
#          exit(0)

#         correction for low minimum temperature
          dtga *= interpolate(AmaxReductionMinAirTemp, aMeteo.minTemp)
#         actual assimilation in kg ch2o per ha
          pgass = dtga * 30.0 / 44.0

#         water stress reduction of pgass to gass and limited attainable maximum
          gass = fTemperature * fMoisture * pgass

#         relative management factor that reduces crop growth
          gass = gass * relmf

#         respiration and partitioning of carbohydrates between growth and maintenance respiration
          rmres = (rmr * cropYield[aDay-1].temperature.roots.living +
                    rml * cropYield[aDay-1].temperature.leaves.living +
                    rms * cropYield[aDay-1].temperature.stem.living) *
                    interpolate(SenescenceReductionDaynumber,t)
          teff = q10^((aMeteo.aveTemp - 25.0) / 10.0)
          mres = min(gass, rmres * teff)
          asrc = gass - mres
#         println(t,"   ",asrc,"   ",gass,"   ",mres,"    ",rmres,"    ",teff)

#         partitioning factors
          fr = interpolate(GrowthPartToRootsDaynumber, t)
          fl = interpolate(GrowthPartToLeavesDaynumber, t)
          fs = interpolate(GrowthPartToStemsDaynumber, t)
#         check on partitioning
          fcheck = fr + (fl + fs) * (1.0 - fr) - 1.0
          if abs(fcheck) > 0.0001
            println("???ERROR in partitioning: sum=",fcheck)
          end

#         dry matter increase
          cvf = 1.0 / ((fl / cvl + fs / cvs) * (1.0 - fr) +fr / cvr)
          dmi = cvf * asrc
#          println(dmi)
#         check on carbon balance
          ccheck = (gass - mres - (fr + (fl + fs) * (1.0 - fr)) * dmi / cvf) / max(0.0001,gass)
          if abs(ccheck) > 0.0001
            println("???ERROR: The carbon balance is not correct")
          end

#         growth rate by plant organ

#         growth rate roots and aerial parts
#         after reaching a live weight of wrtmax(default 2500 kg), the
#         growth of the roots is balanced by the death of root tissue
          deathRateOfRoots = fTemperature * cropYield[aDay-1].temperature.roots.living * interpolate(RelativeDeathRateOfRootsDaynumber,t)
          growthRateOfRoots = fr * dmi
          newWeight = cropYield[aDay-1].temperature.roots.living + growthRateOfRoots - deathRateOfRoots
          if newWeight > maximumRootWeight
            growthRateOfRoots = max(0.0, growthRateOfRoots  - (newWeight - maximumRootWeight))
            deathRateOfRoots = max(0.0, cropYield[aDay-1].temperature.roots.living + growthRateOfRoots - maximumRootWeight)
          end
#          println("gr=", growthRateOfRoots,"   dr=", deathRateOfRoots, "  living=", cropYield[aDay-1].temperature.roots.living, "  dead=",cropYield[aDay-1].temperature.roots.dead)

#         growth rate leaves
#         weight of new leaves
          admi = (1.0 - fr) * dmi
          growthRateLeaves = fl * admi

#         death of leaves due to water stress, temperature or high lai
          dslv1 = growthRateLeaves * fTemperature * (1.0 - fMoisture) * RelativeDeathRateOfLeavesByWaterStress
          laicr = 3.2/kdif
          dslv2 = cropYield[aDay-1].temperature.leaves.living * max(0.0, min(0.03,0.03 * (cropYield[aDay-1].temperature.lai - laicr) / laicr))
          deathRateLeavesLai = max(dslv1, dslv2)

#         death of leaves due to exceeding life span;
#         leaf death is imposed on array until no more leaves have
#         to die or all leaves are gone

          deathRateLeavesAge = 0.0
          fysdel = max(0.0, (aMeteo.aveTemp - thresholdTempLeafAgeing)/(35.0 - thresholdTempLeafAgeing))
          for i in lastDayMowedTemperature + 1 : aDay-1
            cropYield[i].temperature.leaveAge += fysdel
            if cropYield[i].temperature.leaveAge > maxAgeOfLeaves && cropYield[i].temperature.leaves.living > 0.0
              if cropYield[i].dailyTemperatureGrowth.leaves.living > 0.0
                deathRateLeavesAge += cropYield[i].dailyTemperatureGrowth.leaves.living
                global cropYield[i].dailyTemperatureGrowth.leaves.dead += cropYield[i].dailyTemperatureGrowth.leaves.living
                global cropYield[i].dailyTemperatureGrowth.leaves.living = 0.0
              end
            end
          end

#         leaf area not to exceed exponential growth curve
          glaiexp = 0.0
          slatpot = interpolate(SpecificLeafAreaDaynumber, t)
          if cropYield[aDay-1].temperature.laiExp < 6.0
            dteff = max(0.0, aMeteo.aveTemp - thresholdTempLeafAgeing)
            glaiexp = cropYield[aDay-1].temperature.laiExp * dteff * rgrlai
            glasol = growthRateLeaves * slatpot
            gla = min(glaiexp,glasol)
#           adjustment of specific leaf area of youngest leaf class
            if growthRateLeaves > 0.0
              slat = gla/growthRateLeaves
            end
          end

#         lai in case of exponential growthRateStem
          global cropYield[aDay].temperature.laiExp += glaiexp

#         growth rate stems
          wst = cropYield[aDay-1].temperature.stem.living
          growthRateStem = fs*admi
#         death of stems due to water stress is zero in case of actual growth
          deathRateStem1 = growthRateStem * fTemperature *(1.0 - fMoisture) * RelativeDeathRateOfLeavesByWaterStress
#         death of stems due to ageing
          deathRateStem2 = interpolate(RelativeDeathRateOfStemsDaynumber, t) * wst
          deathRateStem = deathRateStem1 + deathRateStem2

#         integrals of the crop
#         dry weight of living plant organs
          global cropYield[aDay].dailyTemperatureGrowth.leaves.living = growthRateLeaves - deathRateLeavesLai
          global cropYield[aDay].temperature.leaves.living = max(0.0, cropYield[aDay-1].temperature.leaves.living + growthRateLeaves - deathRateLeavesLai - deathRateLeavesAge)
          global cropYield[aDay].dailyTemperatureGrowth.roots.living = growthRateOfRoots
          global cropYield[aDay].temperature.roots.living = cropYield[aDay-1].temperature.roots.living + growthRateOfRoots - deathRateOfRoots
          global cropYield[aDay].dailyTemperatureGrowth.stem.living = growthRateStem - deathRateStem
          global cropYield[aDay].temperature.stem.living = cropYield[aDay-1].temperature.stem.living + growthRateStem - deathRateStem

#         dry weight of dead plant organs (roots,leaves & stems)
          global cropYield[aDay].dailyTemperatureGrowth.roots.dead =  deathRateOfRoots
          global cropYield[aDay].temperature.roots.dead = cropYield[aDay-1].temperature.roots.dead + deathRateOfRoots
          global cropYield[aDay].temperature.leaves.dead = cropYield[aDay-1].temperature.leaves.dead + deathRateLeavesLai + deathRateLeavesAge
          global cropYield[aDay].dailyTemperatureGrowth.stem.dead = deathRateStem
          global cropYield[aDay].temperature.stem.dead = cropYield[aDay-1].temperature.stem.dead + deathRateStem

#         total
          global cropYield[aDay].temperature.total.living = cropYield[aDay].temperature.leaves.living + cropYield[aDay].temperature.stem.living
          global cropYield[aDay].temperature.total.dead = cropYield[aDay].temperature.leaves.dead + cropYield[aDay].temperature.stem.dead

#         mowing
          mowingRequired = false
          if gettingMowingDaysTemperature
            if (cropYield[aDay].temperature.total.living + cropYield[aDay].temperature.total.dead > tresholdForMowing && aDay < lastAllowedMowingDay) ||
               (aDay == lastAllowedMowingDay && cropYield[aDay].temperature.total.living + cropYield[aDay].temperature.total.dead >= tresholdForLastMowing)
              global mowingRequired = true
              global nMowingDaysTemperature += 1
              resize!(mowingDayTemperature, nMowingDaysTemperature)
              global mowingDayTemperature[nMowingDaysTemperature] = aDay
            end
          else
            for i in 1:nMowingDaysTemperature
              if mowingDayTemperature[i] == aDay
                global mowingRequired = true
                break
              end
            end
          end

          if mowingRequired
            global lastDayMowedTemperature = aDay
            mowed = cropYield[aDay].temperature.total.living + cropYield[aDay].temperature.total.dead - 700.0
            if mowed < 2000.0
              global delayInTemperatureRegrowth = 2
            else
              if mowed < 4000.0
                global delayInTemperatureRegrowth = 3
              else
                global delayInTemperatureRegrowth = 4
              end
            end

            global cropYield[aDay].dailyTemperatureGrowth.total.living = 0.0
            global cropYield[aDay].dailyTemperatureGrowth.total.dead = 0.0
            global cropYield[aDay].temperature.total.living = 700.0
            global cropYield[aDay].temperature.total.dead = 0.0

            global cropYield[aDay].dailyTemperatureGrowth.mowed = mowed

            fl = interpolate(GrowthPartToLeavesDaynumber, t)
            fs = interpolate(GrowthPartToStemsDaynumber, t)

            global cropYield[aDay].temperature.leaves.living = fl * 700.0
            global cropYield[aDay].temperature.stem.living = fs * 700.0
            global cropYield[aDay].temperature.leaves.dead = fl * 0.0
            global cropYield[aDay].temperature.stem.dead = fs * 0.0
          end
        end
        global cropYield[aDay].temperature.rootingDepth = interpolate(RootDepthRootWeight,cropYield[aDay].temperature.roots.living + cropYield[aDay].temperature.roots.dead)
        global cropYield[aDay].temperature.lai = cropYield[aDay].temperature.leaves.living * interpolate(SpecificLeafAreaDaynumber, 0.0)
        global cropYield[aDay].temperature.mowed = cropYield[aDay-1].temperature.mowed + mowed
#        println(aDay,"   ",cropYield[aDay].temperature.total.living,"   ",cropYield[aDay-1].temperature.mowed,"    ",cropYield[aDay].temperature.mowed, "   ", mowed)
      catch e
        println("???ERROR in Grass.temperatureGrassGrowth: ",e)
      end
    finally
    end
  end


  function moistureFactor(aMeteo :: Main.Control.Types.Meteo, aDepth :: Float64)
    fMoisture = 0.0
    try
      try
          hLim = interpolate(moistureLimitEvaporativeDemand, aMeteo.evapPenman)
          global moistureUptakePressureHead[2,1] = hLim

          node = 1
          head = -1.0

          dz = -1.0 * sensorDepth[1]
          head = simulatedHead[aMeteo.dayofyear, (position-1) * size(sensorDepth,1) + node + 1]
          fMoisture += dz * interpolate(moistureUptakePressureHead, head)

          if aDepth < sensorDepth[1]
            while node < size(sensorDepth,1)
              node += 1
              dz = sensorDepth[node-1] - sensorDepth[node]
              head = 0.5 * (simulatedHead[aMeteo.dayofyear, (position-1) * size(sensorDepth,1) + node] + simulatedHead[aMeteo.dayofyear, (position-1) * size(sensorDepth,1) + node + 1])
              if aDepth >= sensorDepth[node]
                dz = sensorDepth[node-1] - aDepth
                node = size(sensorDepth,1)
                h = simulatedHead[aMeteo.dayofyear, (position-1) * size(sensorDepth,1) + node] + (simulatedHead[aMeteo.dayofyear, (position-1) * size(sensorDepth,1) + node + 1] -
                    simulatedHead[aMeteo.dayofyear, (position-1) * size(sensorDepth,1) + node]) * (aDepth - sensorDepth[node-1]) / (sensorDepth[node] - sensorDepth[node-1])
                head = 0.5 * (simulatedHead[aMeteo.dayofyear, (position-1) * size(sensorDepth,1) + node] + h)
              end
              fMoisture += dz * interpolate(moistureUptakePressureHead, head)
            end
          end
          fMoisture = fMoisture / abs(aDepth)
  #        println(fMoisture)
  #        exit(0)
      catch e
        println("???ERROR in Grass.moistureFactor: ",e)
      end
    finally
    end
    return fMoisture
  end

  function temperatureFactor(aMeteo :: Main.Control.Types.Meteo, aDepth :: Float64)
    fTemperature = 0.0
    try
      try
          dz = -1.0 * sensorDepth[1]
          node = 1
          temp = simulatedTemperature[aMeteo.dayofyear, (position-1) * size(sensorDepth,1) + node + 1]
          fTemperature += dz * interpolate(growthFactorTemperature, temp)

          if aDepth < sensorDepth[1]
            while node < size(sensorDepth,1)
              node += 1
              dz = sensorDepth[node-1] - sensorDepth[node]
              temp = 0.5 * (simulatedTemperature[aMeteo.dayofyear, (position-1) * size(sensorDepth,1) + node] + simulatedTemperature[aMeteo.dayofyear, (position-1) * size(sensorDepth,1) + node + 1])
              if aDepth >= sensorDepth[node]
                dz = sensorDepth[node-1] - aDepth
                node = size(sensorDepth,1)
                t = simulatedTemperature[aMeteo.dayofyear, (position-1) * size(sensorDepth,1) + node] +
                    (simulatedTemperature[aMeteo.dayofyear, (position-1) * size(sensorDepth,1) + node + 1] -
                    simulatedTemperature[aMeteo.dayofyear, (position-1) * size(sensorDepth,1) + node]) *
                    (aDepth - sensorDepth[node-1]) / (sensorDepth[node] - sensorDepth[node-1])
                temp = 0.5 * (simulatedTemperature[aMeteo.dayofyear, (position-1) * size(sensorDepth,1) + node] + t)
              end
              fTemperature += dz * interpolate(growthFactorTemperature, temp)
            end
          end
          fTemperature = fTemperature / abs(aDepth)
#        println(aDepth, "   ", temp, "   ", fTemperature)
#        exit(0)
      catch e
        println("???ERROR in Grass.temperatureFactor: ",e)
      end
    finally
    end
    return fTemperature
  end

  function computePotentialPlantEvaporation(aMeteo :: Main.Control.Types.Meteo, aDay :: Int64)
    try
      try
        if aDay > 1
#         potential
          epp = aMeteo.evapPenman * (1.0 - exp(-1.0 * kdif * kdir * cropYield[aDay-1].potential.lai))
          global cropYield[aDay].dailyPotentialGrowth.potentialPlantEvaporation = epp
          global cropYield[aDay].potential.potentialPlantEvaporation =  cropYield[aDay-1].potential.potentialPlantEvaporation + epp

#          actual
          epp = aMeteo.evapPenman * (1.0 - exp(-1.0 * kdif * kdir * cropYield[aDay-1].actual.lai))
          global cropYield[aDay].dailyActualGrowth.potentialPlantEvaporation = epp
          global cropYield[aDay].actual.potentialPlantEvaporation =  cropYield[aDay-1].actual.potentialPlantEvaporation + epp

#         temperature
          epp = aMeteo.evapPenman * (1.0 - exp(-1.0 * kdif * kdir * cropYield[aDay-1].temperature.lai))
          global cropYield[aDay].dailyTemperatureGrowth.potentialPlantEvaporation = epp
          global cropYield[aDay].temperature.potentialPlantEvaporation =  cropYield[aDay-1].temperature.potentialPlantEvaporation + epp

#         moisture
          epp = aMeteo.evapPenman * (1.0 - exp(-1.0 * kdif * kdir * cropYield[aDay-1].moisture.lai))
          global cropYield[aDay].dailyMoistureGrowth.potentialPlantEvaporation = epp
          global cropYield[aDay].moisture.potentialPlantEvaporation =  cropYield[aDay-1].moisture.potentialPlantEvaporation + epp
        end
      catch e
        println("???ERROR in Grass.computePotentialPlantEvaporation: ", e)
      end
    finally
    end
  end

  function actualPlantEvaporation(aFactor :: Float64, aDay :: Int64)
    try
      try
        global cropYield[aDay].dailyPotentialGrowth.actualPlantEvaporation = aFactor * cropYield[aDay].dailyPotentialGrowth.potentialPlantEvaporation
        global cropYield[aDay].potential.actualPlantEvaporation = cropYield[aDay-1].potential.actualPlantEvaporation + cropYield[aDay].dailyPotentialGrowth.actualPlantEvaporation
        global cropYield[aDay].dailyActualGrowth.actualPlantEvaporation = aFactor * cropYield[aDay].dailyActualGrowth.potentialPlantEvaporation
        global cropYield[aDay].actual.actualPlantEvaporation = cropYield[aDay-1].actual.actualPlantEvaporation + cropYield[aDay].dailyActualGrowth.actualPlantEvaporation
        global cropYield[aDay].dailyMoistureGrowth.actualPlantEvaporation = aFactor * cropYield[aDay].dailyMoistureGrowth.potentialPlantEvaporation
        global cropYield[aDay].moisture.actualPlantEvaporation = cropYield[aDay-1].moisture.actualPlantEvaporation + cropYield[aDay].dailyMoistureGrowth.actualPlantEvaporation
        global cropYield[aDay].dailyTemperatureGrowth.actualPlantEvaporation = aFactor * cropYield[aDay].dailyTemperatureGrowth.potentialPlantEvaporation
        global cropYield[aDay].temperature.actualPlantEvaporation = cropYield[aDay-1].temperature.actualPlantEvaporation + cropYield[aDay].dailyTemperatureGrowth.actualPlantEvaporation

      catch e
        println("???ERROR in Grass.actualPlantEvaporation: ", e)
      end
    finally
    end
  end

  function storeDeltaresData(aDay :: Int64)
    try
      try
          global soilTemperatureAt10cm[aDay] = simulatedTemperature[aDay, (position-1) * size(sensorDepth,1) + 2]
          global soilTemperatureAt20cm[aDay] = simulatedTemperature[aDay, (position-1) * size(sensorDepth,1) + 3]
          global soilTemperatureAt40cm[aDay] = simulatedTemperature[aDay, (position-1) * size(sensorDepth,1) + 5]
          global pressureHeadAt10cm[aDay] = simulatedHead[aDay, (position-1) * size(sensorDepth,1) + 2]
          global pressureHeadAt20cm[aDay] = simulatedHead[aDay, (position-1) * size(sensorDepth,1) + 3]
          global pressureHeadAt40cm[aDay] = simulatedHead[aDay, (position-1) * size(sensorDepth,1) + 5]
     #      println(pressureHeadAt40cm[aDay])
      catch e
        println("???ERROR in Grass.storeDeltaresData: ", e)
      end
    finally
    end
  end

  function computeGrowth(aMeteo :: Main.Control.Types.Meteo)
#    x1 = interpolate(CropFactorDaynumber,1.2)
#    x2 = interpolate(SpecificLeafAreaDaynumber,135.5)
#    x3 = interpolate(AssimilationRateDayNumber, 210.0)
#    x4 = interpolate(AmaxReductionMinAirTemp, 10.0)
#    println(x1, "   ", x2,"    ", x3,"    ",x4)
    fMoisture = 1.0
    fTemperature = 1.0

    try
      try
        day = aMeteo.dayofyear
#        println(day)
        global cropYield[day].dayofyear = day
        global cropYield[day].potentialEp = aMeteo.evapPenman

#       store soil data
        storeDeltaresData(day)

#        grassIsGrowing = true
#        aMeteo.radiation = 7000.0
        if !grassIsGrowing
          beforeGrassGrowth(aMeteo)
#          println(temperatureSum)
        else
#         compute potential plant evaporation
          computePotentialPlantEvaporation(aMeteo, day)
#         read data from Deltares
          drz = cropYield[day-1].actual.rootingDepth
          fMoisture = moistureFactor(aMeteo, drz)
          fTemperature = temperatureFactor(aMeteo, drz)
          actualPlantEvaporation(fMoisture, day)
#          println(fMoisture, "   ", fTemperature)
#         potential growth
          potentialGrassGrowth(aMeteo, day)
#         actual growth
          actualGrassGrowth(aMeteo, day, fMoisture, fTemperature)
          moistureGrassGrowth(aMeteo, day, fMoisture)
          temperatureGrassGrowth(aMeteo,day, fTemperature)
        end
        global cropDate[day] = aMeteo.date
        global cropYieldPotentialLiving[day] = cropYield[day].potential.total.living + cropYield[day].potential.total.dead
        global cropYieldActualLiving[day] = cropYield[day].actual.total.living + cropYield[day].actual.total.dead
        global cropYieldMoistureLiving[day] = cropYield[day].moisture.total.living + cropYield[day].moisture.total.dead
        global cropYieldTemperatureLiving[day] = cropYield[day].temperature.total.living + cropYield[day].temperature.total.dead
        global mowedPotential[day] = cropYield[day].potential.mowed
        global mowedActual[day] = cropYield[day].actual.mowed
        global mowedMoisture[day] = cropYield[day].moisture.mowed
        global mowedTemperature[day] = cropYield[day].temperature.mowed
        global laiPotential[day] = cropYield[day].potential.lai
        global laiActual[day] = cropYield[day].actual.lai
        global laiMoisture[day] = cropYield[day].moisture.lai
        global laiTemperature[day] = cropYield[day].temperature.lai
        global factorMoisture[day] = fMoisture
        global factorTemperature[day] = fTemperature
        global eppPotential[day] = cropYield[day].potential.potentialPlantEvaporation
        global eppActual[day] = cropYield[day].actual.potentialPlantEvaporation
        global eppMoisture[day] = cropYield[day].moisture.potentialPlantEvaporation
        global eppTemperature[day] = cropYield[day].temperature.potentialPlantEvaporation
        global epaPotential[day] = cropYield[day].potential.actualPlantEvaporation
        global epaActual[day] = cropYield[day].actual.actualPlantEvaporation
        global epaMoisture[day] = cropYield[day].moisture.actualPlantEvaporation
        global epaTemperature[day] = cropYield[day].temperature.actualPlantEvaporation

#        global cropYieldPotentialDead[day] = cropYield[day].potential.dailyGrowth.dead

  #      println(day, "   ", cropYield[day].potentialEp, "   ", cropYield[day].actualEp)
      catch e
        println("???ERROR in Grass.computeGrowth: ",e)
    end
    finally
    end
  end

  function plotGrass()
    try
      try
        p = Plots.Plot{Plots.GRBackend}[]
        resize!(p,8)
        p[1] = plot(legend=:topleft, xlabel="Date", ylabel="Grass yield (kg dm/ha)", size=(750,500))
        p[1] = plot!(p[1], cropDate, cropYieldPotentialLiving, label="P", color=:darkgoldenrod2, linestyle=:solid)
        p[1] = plot!(p[1], cropDate, cropYieldActualLiving, label="A", color=:darkred, linestyle=:solid)
        p[1] = plot!(p[1], cropDate, cropYieldMoistureLiving, label="M", color=:blue, linestyle=:solid)
        p[1] = plot!(p[1], cropDate, cropYieldTemperatureLiving, label="T", color=:green2, linestyle=:solid)

        p[2] = plot(legend=:topleft, xlabel="Date", ylabel="Mowed (kg dm/ha)", size=(750,500))
        p[2] = plot!(p[2], cropDate, mowedPotential, label="P", color=:darkgoldenrod2, linestyle=:solid)
        p[2] = plot!(p[2], cropDate, mowedActual, label="A", color=:darkred, linestyle=:solid)
        p[2] = plot!(p[2], cropDate, mowedMoisture, label="M", color=:blue, linestyle=:solid)
        p[2] = plot!(p[2], cropDate, mowedTemperature, label="T", color=:green2, linestyle=:solid)

        p[3] = plot(legend=:topleft, xlabel="Date", ylabel="LAI (m2/m2)", size=(750,500))
        p[3] = plot!(p[3], cropDate, laiPotential, label="P", color=:darkgoldenrod2, linestyle=:solid)
        p[3] = plot!(p[3], cropDate, laiActual, label="A", color=:darkred, linestyle=:solid)
        p[3] = plot!(p[3], cropDate, laiMoisture, label="M", color=:blue, linestyle=:solid)
        p[3] = plot!(p[3], cropDate, laiTemperature, label="T", color=:green2, linestyle=:solid)

        p[4] = plot(legend=:none, xlabel="Datum", ylabel="Factor (-)", size=(750,500))
#        p[4] = plot!(p[4], cropDate, factorMoisture, label="Moisture", color=:blue, linestyle=:solid)
        p[4] = plot!(p[4], cropDate, factorTemperature, label="Temperature", color=:red, linestyle=:solid)
        savefig("/home/wesseling/DataDisk/Wesseling/Work/Waterstof/Output/Grass/factor_" * string(year) * "_" * string(profile) * "_" * string(position) * ".svg")

        p[5] = plot(legend=:topleft, xlabel="Date", ylabel="Epp (mm)", size=(750,500))
        p[5] = plot!(p[5], cropDate, eppPotential, label="P", color=:darkgoldenrod2, linestyle=:solid)
        p[5] = plot!(p[5], cropDate, eppActual, label="A", color=:darkred, linestyle=:solid)
        p[5] = plot!(p[5], cropDate, eppMoisture, label="M", color=:blue, linestyle=:solid)
        p[5] = plot!(p[5], cropDate, eppTemperature, label="T", color=:green2, linestyle=:solid)

        p[6] = plot(legend=:topleft, xlabel="Date", ylabel="Epa (mm)", size=(750,500))
        p[6] = plot!(p[6], cropDate, epaPotential, label="P", color=:darkgoldenrod2, linestyle=:solid)
        p[6] = plot!(p[6], cropDate, epaActual, label="A", color=:darkred, linestyle=:solid)
        p[6] = plot!(p[6], cropDate, epaMoisture, label="M", color=:blue, linestyle=:solid)
        p[6] = plot!(p[6], cropDate, epaTemperature, label="T", color=:green2, linestyle=:solid)

        p[7] = plot(legend=:topleft, xlabel="Date", ylabel="Temperature (C)", size=(750,500))
        p[7] = plot!(p[7], cropDate, soilTemperatureAt10cm, label = "10 cm", color=:darkred, linestyle=:solid)
        p[7] = plot!(p[7], cropDate, soilTemperatureAt20cm, label = "20 cm", color=:blue, linestyle=:solid)
        p[7] = plot!(p[7], cropDate, soilTemperatureAt40cm, label = "40 cm", color=:green2, linestyle=:solid)

        p[8] = plot(legend=:topleft, xlabel="Date", ylabel="Pressure head (cm)", size=(750,500))
        p[8] = plot!(p[8], cropDate, pressureHeadAt10cm, label = "10 cm", color=:darkred, linestyle=:solid)
        p[8] = plot!(p[8], cropDate, pressureHeadAt20cm, label = "20 cm", color=:blue, linestyle=:solid)
        p[8] = plot!(p[8], cropDate, pressureHeadAt40cm, label = "40 cm", color=:green2, linestyle=:solid)
        pAll = plot(p..., layout=(4,2), size=(1500,2000))

        savefig("/home/wesseling/DataDisk/Wesseling/Work/Waterstof/Output/Grass/cropyield_" * string(year) * "_" * string(profile) * "_" * string(position) * ".svg")

        display(pAll)

      catch e
        println("???ERROR in Grass.plotGrass: ", e)
      end
    finally
    end
  end

  function storeOutput()
    fileName = "/home/wesseling/DataDisk/Wesseling/Work/Waterstof/Output/Grass/results_" * string(year) * "_" * string(profile) * "_" * string(position) * ".txt"
    df = DateFormat("dd-u-yyyy HH:MM:SS.sss")
    df1 = DateFormat("dd-u-yyyy")

    try
      try
        myString = "Results of CropGrowth. \nDate : " * Dates.format(Dates.now(),df) * "\n\n"
        myString *= "Item                       Potential         Actual       Moisture    Temperature\n"

        myString *= "Epp (mm) till 15/10  "
        myString *= lpad(string(floor(Int64,cropYield[289].potential.potentialPlantEvaporation)),15," ")
        myString *= lpad(string(floor(Int64,cropYield[289].actual.potentialPlantEvaporation)),15," ")
        myString *= lpad(string(floor(Int64,cropYield[289].moisture.potentialPlantEvaporation)),15," ")
        myString *= lpad(string(floor(Int64,cropYield[289].temperature.potentialPlantEvaporation)),15," ")
        myString *= "\n"

        myString *= "Epa (mm) till 15/10  "
        myString *= lpad(string(floor(Int64,cropYield[289].potential.actualPlantEvaporation)),15," ")
        myString *= lpad(string(floor(Int64,cropYield[289].actual.actualPlantEvaporation)),15," ")
        myString *= lpad(string(floor(Int64,cropYield[289].moisture.actualPlantEvaporation)),15," ")
        myString *= lpad(string(floor(Int64,cropYield[289].temperature.actualPlantEvaporation)),15," ")
        myString *= "\n"
        global actualTranspiration = string(floor(Int64,cropYield[289].actual.actualPlantEvaporation))

        myString *= "First harvest       "
        s = "Unknown"
        i = 0
        while i < 289
          i+=1
          if cropYield[i].potential.mowed > 1.0
            s = lpad(Dates.format(cropYield[i].theDate, df1), 15, " ")
            i = break
          end
        end
        myString *= s
        s = "Unknown"
        i = 0
        while i < 289
          i+=1
          if cropYield[i].actual.mowed > 1.0
            s = lpad(Dates.format(cropYield[i].theDate, df1), 15, " ")
            global firstMowingDate = Dates.format(cropYield[i].theDate, df1)
            break
          end
        end
        myString *= s
        s = "Unknown"
        i = 0
        while i < 289
          i+=1
          if cropYield[i].moisture.mowed > 1.0
            s = lpad(Dates.format(cropYield[i].theDate, df1), 15, " ")
            break
          end
        end
        myString *= s
        s = "Unknown"
        i = 0
        while i < 289
          i+=1
          if cropYield[i].temperature.mowed > 1.0
            s = lpad(Dates.format(cropYield[i].theDate, df1), 15, " ")
            break
          end
        end
        myString *= s
        myString *= "\n"

        myString *= "Harvest (kg/ha)     "
        myString *= lpad(string(floor(Int64,cropYield[289].potential.mowed)),15," ")
        myString *= lpad(string(floor(Int64,cropYield[289].actual.mowed)),15," ")
        myString *= lpad(string(floor(Int64,cropYield[289].moisture.mowed)),15," ")
        myString *= lpad(string(floor(Int64,cropYield[289].temperature.mowed)),15," ")
        myString *= "\n"
        global harvested = string(floor(Int64,cropYield[289].actual.mowed))

        myString *= "Yield at 15 oct.     "
        myString *= lpad(string(floor(Int64,cropYield[289].potential.total.dead + cropYield[289].potential.total.living)),15," ")
        myString *= lpad(string(floor(Int64,cropYield[289].actual.total.dead + cropYield[289].actual.total.living)),15," ")
        myString *= lpad(string(floor(Int64,cropYield[289].moisture.total.dead + cropYield[289].moisture.total.living)),15," ")
        myString *= lpad(string(floor(Int64,cropYield[289].temperature.total.dead + cropYield[289].temperature.total.living)),15," ")
        myString *= "\n"
        global leftAtField = string(floor(Int64,cropYield[289].actual.total.dead + cropYield[289].actual.total.living))
        outFile = open(fileName, "w")
        println(outFile, myString)
        close(outFile)

#        pot = cropYield[289].potential.mowed + cropYield[289].potential.total.dead + cropYield[289].potential.total.living
#        tmp = cropYield[289].temperature.mowed + cropYield[289].temperature.total.dead + cropYield[289].temperature.total.living
#        dif = tmp - pot
#        proc = 100 * dif / pot
#        println(pot, "   ", tmp, "   ", dif, "   ", proc)
      catch e
        println("????ERROR in Grass.storeOutput: ",e)
        exit(0)
      end
    finally
    end
  end

end
