module Potato
# all depths in cm!!!!
  using Interpolations
  using Dates
  using OffsetArrays
  using Plots
  using Colors
  using CSV
  using DataFrames

  fixedEmergence = true

  Gauss3x = [0.1127017, 0.5000000, 0.8872983]
  Gauss3w = [0.2777778, 0.4444444, 0.2777778]

  sensorDepth = [-0.1, -0.2, -0.3, -0.4, -0.5, -0.75, -1.0] # m
  sensorDistance = [0.0, 1.0, 2.0, 5.0, 10.0] # m

  plantingDepth = -0.2
  plantingDay = 91

  CropFactorDvs = [0.0 1.0;
                   1.0 1.1;
                   2.0 1.1]

  CropHeightDvs = [0.0 1.0;
                   1.0 40.0;
                   2.0 50.0]

  degDaysPlantingEmergence = 170.0
  degDaysEmergenceAnthesis = 150.0
  degDaysAnthesisMaturity = 1550.0

  minTempEmergence = 3.0
  maxTempEmergence = 18.0
  minHeadEmergence = -500.0
  maxHeadEmergence = -100.0
  aEmergence = 203.0
  bEmergence = 522.0
  cEmergence = -432.0

  deltaTempSumAirTemp = [0.0 0.0;
                         2.0 0.0;
                         13.0 11.0;
                         30.0 28.0]

  albedo = 0.23
  minCanopyResistance = 100.0
  canopyResistanceInterceptedWater = 0.0

  dayOfEmergence = 0
  initialRootDepth = 0.0
  initialTotalWeight = 75.0
  laiAtEmergence = 0.0589
  maxRelativeLaiIncrease = 0.012

  SpecificLeafAreaDvs = [1.00 0.0030;
                         1.10 0.0030;
                         2.00 0.0015]
  specificPodArea = 0.0
  specificStemArea = 0.0
  maxAgeOfLeaves = 43.0
#  maxAgeOfLeaves = 37.0
  baseTempLeafAgeing = 2.0

  kDif = 1.0
  kDir = 0.75
  eff = 0.45

  AssimilationRateDvs = [0.00  30.0;
                         1.57  30.0;
                         2.00  0.00]

  AmaxReductionAverageAirTemp =[0.00   0.010;
                                3.00   0.010;
                               10.00   0.750;
                               15.00   1.000;
                               20.00   1.000;
                               26.00   0.750;
                               33.00   0.010]

  AmaxReductionMinAirTemp = [0.00  0.000;
                             3.00  1.000]

  cvl = 0.720
  cvo = 0.850
  cvr = 0.720
  cvs = 0.690

  rml = 0.0300
  rmr = 0.0100
  rmo = 0.0045
  rms = 0.0150
  q10 = 2.0


  SenescenceReductionDvs = [0.00 1.0000;
                            2.00 1.0000]

  GrowthPartToRootsDvs = [0.00 0.2000;
                          1.00 0.2000;
                          1.36 0.0000;
                          2.00 0.0000]

  GrowthPartToLeavesDvs = [0.00 0.8000;
                           1.00 0.8000;
                           1.27 0.0000;
                           2.00 0.0000]

  GrowthPartToStemsDvs = [0.00 0.2000;
                          1.00 0.2000;
                          1.27 0.2500;
                          1.36 0.0000;
                          2.00 0.0000]

  GrowthPartToStorageDvs = [0.00 0.000;
                            1.00 0.000;
                            1.27 0.750;
                            1.36 1.000;
                            2.00 1.000]

  RelativeDeathRateOfRootsDvs = [0.0000 0.0000;
                                 1.5000 0.0000;
                                 1.5001 0.0200;
                                 2.0000 0.0200]

  RelativeDeathRateOfStemsDvs = [0.0000 0.0000;
                                 1.5000 0.0000;
                                 1.5001 0.0200;
                                 2.0000 0.0200]

  RelativeDeathRateOfLeavesByWaterStress = 0.030

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

  moistureUptakePressureHead = [-10000.0 0.0;
                                -300.0 1.0;
                                -25.0 1.0
                                -10.0 0.0;
                                 0.0 0.0]


  moistureLimitEvaporativeDemand = [1.0  -500.0;
                                    5.0  -300.0]

  AmaxFactorSoilTemperature1 = [5.0 0.5;
                            8.0 1.0;
                            15.0 1.0;
                            30.0 0.5]

  AmaxFactorSoilTemperature2 = [5.0 0.7;
                                16.0 1.0;
                                25.0 1.0;
                                30.0 0.7;
                                40.0 0.1]

  DvsFactorSoilTemperature1 = [5.0 0.9;
                               8.0 1.0;
                               15.0 1.0;
                               30.0 0.8]

  DvsFactorSoilTemperature2 = [10.0 0.7;
                               16.0 1.0;
                               25.0 1.0;
                               30.0 0.7]

  maximumRootingDepth = 50.0
  maximumRootWeight = 4000.0
  thresholdTempLeafAgeing = 0.0
  specificStemArea = 0.0004


  latitude = 51.962
  longitude = 4.447

  rgrlai = 0.007
  relmf = 0.9

  year = 0
  position = 0
  profile = 0

  isPlanted = false
  cropIsGrowing = false

  tempSumEmergence = 0.0

  cropYield = OffsetArray{Main.Control.Types.CropYield}
  cropDate = Array{Dates.Date}(undef,365)
  cropYieldPotentialLiving = Array{Float64}(undef,365)
  cropYieldActualLiving = Array{Float64}(undef,365)
  cropYieldMoistureLiving = Array{Float64}(undef,365)
  cropYieldTemperatureLiving = Array{Float64}(undef,365)
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
  soilTemperatureAt30cm = Array{Float64}(undef,365)
  soilTemperatureAt40cm = Array{Float64}(undef,365)
  pressureHeadAt10cm = Array{Float64}(undef,365)
  pressureHeadAt20cm = Array{Float64}(undef,365)
  pressureHeadAt30cm = Array{Float64}(undef,365)
  pressureHeadAt40cm = Array{Float64}(undef,365)

  simulatedHead = undef
  simulatedTemperature = undef

  actualYield = 0.0
  actualDateMature = ""
  actualDateEmergence = ""
  actualTranspiration = 0.0

  moistureYield = 0.0
  temperatureYield = 0.0
  potentialYield = 0.0

  function setSimulatedData(aHead :: DataFrame, aTemp :: DataFrame)
    try
      try
        global simulatedHead = aHead
        global simulatedTemperature = aTemp
      catch e
        println("???ERROR in Potato.setSimulatedData: ",e)
      end
    finally
#      println(simulatedHead[180,2])
    end
  end

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

  function initialize(aYear :: Int64, aProfile :: Int64, aPosition :: Int64)
    try
      try
        global cropIsGrowing = false
        global isPlanted = false
        if fixedEmergence
          global dayOfEmergence = 115
        else
          global dayOfEmergence = -1
        end
        global tempSumEmergence = 0.0
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
    catch e
      println("???ERROR in Potato.initialize: ",e)
    end
    finally
    end
  end

  function setDataForEmergence()
    try
      try
        fr = interpolate(GrowthPartToRootsDvs, 0.0)
        fl = interpolate(GrowthPartToLeavesDvs, 0.0)
        fs = interpolate(GrowthPartToStemsDvs, 0.0)

        global cropYield[dayOfEmergence].potential.leaves.living = (1.0 - fr) * fl * initialTotalWeight
        global cropYield[dayOfEmergence].potential.stem.living = (1.0 - fr) * fs * initialTotalWeight
        global cropYield[dayOfEmergence].potential.shoot.living = (1.0 - fr) * (1.0 - fl - fs) * initialTotalWeight
        global cropYield[dayOfEmergence].potential.total.dead = 0.0
        global cropYield[dayOfEmergence].potential.roots.dead = 0.0
        global cropYield[dayOfEmergence].potential.leaves.dead = 0.0
        global cropYield[dayOfEmergence].potential.stem.dead = 0.0
        global cropYield[dayOfEmergence].potential.shoot.dead = 0.0
        global cropYield[dayOfEmergence].potential.rootingDepth = interpolate(RootDepthRootWeight,cropYield[dayOfEmergence].potential.roots.living)
        global cropYield[dayOfEmergence].potential.lai = cropYield[dayOfEmergence].potential.leaves.living * interpolate(SpecificLeafAreaDvs, 0.0)
        global cropYield[dayOfEmergence].potential.laiExp = cropYield[dayOfEmergence].potential.lai
        global cropYield[dayOfEmergence].potential.total.living = cropYield[dayOfEmergence].potential.leaves.living + cropYield[dayOfEmergence].potential.stem.living

        global cropYield[dayOfEmergence].actual.total.living = cropYield[dayOfEmergence].potential.total.living
        global cropYield[dayOfEmergence].potential.roots.living = fr * initialTotalWeight
        global cropYield[dayOfEmergence].actual.roots.living = cropYield[dayOfEmergence].potential.roots.living
        global cropYield[dayOfEmergence].actual.leaves.living = cropYield[dayOfEmergence].potential.leaves.living
        global cropYield[dayOfEmergence].actual.stem.living = cropYield[dayOfEmergence].potential.stem.living
        global cropYield[dayOfEmergence].actual.shoot.living = cropYield[dayOfEmergence].potential.shoot.living
        global cropYield[dayOfEmergence].actual.total.dead = cropYield[dayOfEmergence].potential.total.dead
        global cropYield[dayOfEmergence].actual.roots.dead = cropYield[dayOfEmergence].potential.roots.dead
        global cropYield[dayOfEmergence].actual.leaves.dead = cropYield[dayOfEmergence].potential.leaves.dead
        global cropYield[dayOfEmergence].actual.stem.dead = cropYield[dayOfEmergence].potential.stem.dead
        global cropYield[dayOfEmergence].actual.shoot.dead = cropYield[dayOfEmergence].potential.shoot.dead
        global cropYield[dayOfEmergence].actual.rootingDepth = cropYield[dayOfEmergence].potential.rootingDepth
        global cropYield[dayOfEmergence].actual.lai = cropYield[dayOfEmergence].potential.lai
        global cropYield[dayOfEmergence].actual.laiExp = cropYield[dayOfEmergence].potential.laiExp

        global cropYield[dayOfEmergence].moisture.total.living = cropYield[dayOfEmergence].potential.total.living
        global cropYield[dayOfEmergence].moisture.roots.living = cropYield[dayOfEmergence].potential.roots.living
        global cropYield[dayOfEmergence].moisture.leaves.living = cropYield[dayOfEmergence].potential.leaves.living
        global cropYield[dayOfEmergence].moisture.stem.living = cropYield[dayOfEmergence].potential.stem.living
        global cropYield[dayOfEmergence].moisture.shoot.living = cropYield[dayOfEmergence].potential.shoot.living
        global cropYield[dayOfEmergence].moisture.total.dead = cropYield[dayOfEmergence].potential.total.dead
        global cropYield[dayOfEmergence].moisture.roots.dead = cropYield[dayOfEmergence].potential.roots.dead
        global cropYield[dayOfEmergence].moisture.leaves.dead = cropYield[dayOfEmergence].potential.leaves.dead
        global cropYield[dayOfEmergence].moisture.stem.dead = cropYield[dayOfEmergence].potential.stem.dead
        global cropYield[dayOfEmergence].moisture.shoot.dead = cropYield[dayOfEmergence].potential.shoot.dead
        global cropYield[dayOfEmergence].moisture.rootingDepth = cropYield[dayOfEmergence].potential.rootingDepth
        global cropYield[dayOfEmergence].moisture.lai = cropYield[dayOfEmergence].potential.lai
        global cropYield[dayOfEmergence].moisture.laiExp = cropYield[dayOfEmergence].potential.laiExp

        global cropYield[dayOfEmergence].temperature.total.living = cropYield[dayOfEmergence].potential.total.living
        global cropYield[dayOfEmergence].temperature.roots.living = cropYield[dayOfEmergence].potential.roots.living
        global cropYield[dayOfEmergence].temperature.leaves.living = cropYield[dayOfEmergence].potential.leaves.living
        global cropYield[dayOfEmergence].temperature.stem.living = cropYield[dayOfEmergence].potential.stem.living
        global cropYield[dayOfEmergence].temperature.shoot.living = cropYield[dayOfEmergence].potential.shoot.living
        global cropYield[dayOfEmergence].temperature.total.dead = cropYield[dayOfEmergence].potential.total.dead
        global cropYield[dayOfEmergence].temperature.roots.dead = cropYield[dayOfEmergence].potential.roots.dead
        global cropYield[dayOfEmergence].temperature.leaves.dead = cropYield[dayOfEmergence].potential.leaves.dead
        global cropYield[dayOfEmergence].temperature.stem.dead = cropYield[dayOfEmergence].potential.stem.dead
        global cropYield[dayOfEmergence].temperature.shoot.dead = cropYield[dayOfEmergence].potential.shoot.dead
        global cropYield[dayOfEmergence].temperature.rootingDepth = cropYield[dayOfEmergence].potential.rootingDepth
        global cropYield[dayOfEmergence].temperature.lai = cropYield[dayOfEmergence].potential.lai
        global cropYield[dayOfEmergence].temperature.laiExp = cropYield[dayOfEmergence].potential.laiExp

        computeRootDepths(dayOfEmergence)

#        println(cropYield[dayOfEmergence].actual.total.living)

      catch e
        println("???ERROR in Potato.setDataForEmergence: ",e)
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
        global cropYield[d].potential.dvs = cropYield[d-1].potential.dvs
        global cropYield[d].potential.tempSum = cropYield[d-1].potential.tempSum

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
        global cropYield[d].dailyPotentialGrowth.dvs = cropYield[d-1].dailyPotentialGrowth.dvs
        global cropYield[d].dailyPotentialGrowth.tempSum = cropYield[d-1].dailyPotentialGrowth.tempSum

      catch e
        println("????ERROR in Potato.copyPotentialValues: ", e)
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
        global cropYield[d].actual.dvs = cropYield[d-1].actual.dvs
        global cropYield[d].actual.tempSum = cropYield[d-1].actual.tempSum

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
        global cropYield[d].dailyActualGrowth.dvs = cropYield[d-1].dailyActualGrowth.dvs
        global cropYield[d].dailyActualGrowth.tempSum = cropYield[d-1].dailyActualGrowth.tempSum
      catch e
        println("????ERROR in Potato.copyActualValues: ", e)
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
        global cropYield[d].moisture.dvs = cropYield[d-1].moisture.dvs
        global cropYield[d].moisture.tempSum = cropYield[d-1].moisture.tempSum

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
        global cropYield[d].dailyMoistureGrowth.dvs = cropYield[d-1].dailyMoistureGrowth.dvs
        global cropYield[d].dailyMoistureGrowth.tempSum = cropYield[d-1].dailyMoistureGrowth.tempSum
      catch e
        println("????ERROR in Potato.copyMoistureValues: ", e)
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
        global cropYield[d].temperature.dvs = cropYield[d-1].temperature.dvs
        global cropYield[d].temperature.tempSum = cropYield[d-1].temperature.tempSum

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
        global cropYield[d].dailyTemperatureGrowth.dvs = cropYield[d-1].dailyTemperatureGrowth.dvs
        global cropYield[d].dailyTemperatureGrowth.tempSum = cropYield[d-1].dailyTemperatureGrowth.tempSum
      catch e
        println("????ERROR in Potato.copyTemperatureValues: ", e)
      end
    finally
    end
  end

  function beforePlanting(aMeteo :: Main.Control.Types.Meteo)
    try
      try
        d = aMeteo.dayofyear
        potentialEp = aMeteo.evapPenman
        actualEp = 0.0
        if d == plantingDay
          global isPlanted = true
        end
      catch e
        println("???ERROR in Potato.beforePlanting: ", e)
      end
    finally
    end
  end

  function computeTemperatureSum(aMeteo :: Main.Control.Types.Meteo)
    try
      try
        # soil temperature and head at planting depth
        dist = 99999.0
        pos = -1
        for i in 1:size(sensorDepth,1)
          d = abs(plantingDepth - sensorDepth[i])
          if d < dist
            dist = d
            pos = i
          end
        end
        colOfTable = (position-1) * size(sensorDepth,1) + pos + 1
        t = simulatedTemperature[aMeteo.dayofyear,colOfTable]
        head = 0.0
        for i in 1:pos
          head  += simulatedHead[aMeteo.dayofyear, (position-1)*size(sensorDepth,1)+i+1]
        end
        head /= pos

        corrSum = degDaysPlantingEmergence
        if head < minHeadEmergence
          corrSum = aEmergence * log10(abs(head)) + cEmergence
        end
        if head > maxHeadEmergence
          corrSum = -1.0 * aEmergence * log10(abs(head)) + bEmergence
        end

        if t > minTempEmergence
          if t < maxTempEmergence
            global tempSumEmergence += (degDaysPlantingEmergence / corrSum) * (t - minTempEmergence)
          else
            global tempSumEmergence += (degDaysPlantingEmergence / corrSum) * (maxTempEmergence - minTempEmergence)
          end
        end
#        println(tempSumEmergence)
        if tempSumEmergence >= degDaysPlantingEmergence
          global dayOfEmergence = aMeteo.dayofyear
        end
      catch e
        println("???ERROR in Potato.computeTemperatureSum: ", e)
      end
    finally
    end
  end

  function beforeCropGrowth(aMeteo :: Main.Control.Types.Meteo)
    try
      try
        d = aMeteo.dayofyear
        potentialEp = aMeteo.evapPenman
        actualEp = 0.0
#        global temperatureSum += max(aMeteo.aveTemp, 0.0)
        if !fixedEmergence
          computeTemperatureSum(aMeteo)
        end
        if d == dayOfEmergence
          setDataForEmergence()
          global cropIsGrowing = true
        end
      catch e
        println("???ERROR in Potato.beforeCropGrowth: ",e)
      end
    finally
    end
  end

  function potentialCropGrowth(aMeteo :: Main.Control.Types.Meteo, aDay :: Int64)
    try
      try

        fMoisture = 1.0
        fTemperature = 1.0

        t =convert(Float64, aDay)
        avrad = 1000.0 * aMeteo.radiation
        scv = 0.2

#       Declination and solar constant for this day
        declination = -asin(sind(23.45) * cos(2.0 * pi * (t+10) /365.0))
        solarConstant  = 1370.0 * (1.0 + 0.033 * cos(2.0*pi*t/365.0))

#       calculation of daylength from intermediate variables
#       SINLD, COSLD and AOB
        sinld = sind(latitude)*sin(declination)
        cosld = cosd(latitude)*cos(declination)
        aob = sinld/cosld

#       Calculate solution for base=0 degrees
        if abs(aob) <= 1.0
          daylength = 12.0 * (1.0 + 2.0 * asin(aob) / pi)
#         integrals of sine of solar height
          dsinb  = 3600.0 * (daylength * sinld + 24.0 * cosld * sqrt(1.0-aob*aob)/pi)
          dsinbe = 3600.0 * (daylength * (sinld + 0.40 * (sinld* sinld + cosld * cosld * 0.5)) + 12.0 * cosld * (2.0 + 3.0 * 0.4 * sinld) * sqrt(1.0 - aob * aob)/pi)
        else
          if aob > 1.0
             daylength = 24.0
          end
          if aob < 1.0
            daylength =  0.0
          end
#         integrals of sine of solar height
          dsinb  = 3600.0 * (daylength * sinld)
          dsinbe = 3600.0 * (daylength * (sinld + 0.4 * (sinld * sinld + cosld * cosld * 0.5)))
        end

#       Calculate solution for base =-4 (ANGLE) degrees
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

#       extraterrestrial radiation and atmospheric transmission
        angot  = solarConstant * dsinb
#       Check for daylength=0 as in that case the angot radiation is 0 as well
        atmtr = 0.0
        if daylength > 0.0
          atmtr = avrad / angot
        end

#       estimate fraction diffuse irradiation
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

        amax = interpolate(AssimilationRateDvs,cropYield[aDay].potential.dvs) * interpolate(AmaxReductionAverageAirTemp, aMeteo.aveTemp)

#       potential growth
        dtga  = 0.0
        if amax > 0.0 && cropYield[aDay-1].potential.lai > 0.0
          for i in 1:3
            hour = 12.0 + daylength * (Gauss3x[i] - 0.5)
            sinb = max(0.0, sinld + cosld *cos(2.0 * pi * (hour + 12.0) / 24.0))
            par = 0.5 * avrad * sinb * (1.0 + 0.4 * sinb) / dsinbe
            pardif = min(par, sinb * difpp)
            pardir = par - pardif

#           extinction coefficients kDif,kDirBL,kDirT, start of assim
            refh   = (1.0 - sqrt(1.0 - scv)) / (1.0 + sqrt(1.0 - scv))
            refs   = refh * 2.0 / (1.0 + 1.6 * sinb)
            kDirbl = (0.5 / sinb) * kDif / (0.8 * sqrt(1.0 - scv))
            kDirt  = kDirbl * sqrt(1.0 - scv)

#           three-point Gaussian integration over LAI
            fgros  = 0.0
            for j in 1:3
              laic   = cropYield[aDay-1].potential.lai * Gauss3x[j]
#             absorbed diffuse radiation (VISDF),light from direct
#             origine (VIST) and direct light(VISD)
              visdf  = (1.0 - refs) * pardif * kDif * exp(-kDif * laic)
              vist   = (1.0 - refs) * pardir * kDirt * exp(-kDirt * laic)
              visd   = (1.0 - scv) * pardir * kDirbl * exp(-kDirbl*laic)
#             absorbed flux in W/m2 for shaded leaves and assimilation
              visshd = visdf + vist - visd
              fgrsh  = amax * (1.0 - exp(-visshd * eff / max(2.0,amax)))
#             direct light absorbed by leaves perpendicular on direct
#             beam and assimilation of sunlit leaf area
              vispp  = (1.0 - scv) * pardir / sinb
              fgrsun = fgrsh
              if vispp > 0.0
                fgrsun = amax * (1.0 - (amax - fgrsh) * (1.0-exp(-vispp * eff / max(2.0,amax))) / (eff * vispp))
              end
#             fraction of sunlit leaf area (FSLLA) and local assimilation rate (FGL)
              fslla  = exp(-kDirbl * laic)
              fgl    = fslla * fgrsun + (1.0 - fslla) * fgrsh
#             integration
              fgros  += fgl * Gauss3w[j]
            end
            fgros  *=  cropYield[aDay-1].potential.lai
#           end of assim
            dtga += fgros * Gauss3w[i]
          end
          dtga = dtga * daylength
        end

#          println(dtga)
#          exit(0)

#       correction for low minimum temperature
        dtga *= interpolate(AmaxReductionMinAirTemp, aMeteo.minTemp)
#       potential assimilation in kg ch2o per ha
        pgass = dtga * 30.0 / 44.0

#       water stress reduction of pgass to gass and limited attainable maximum
        gass = pgass * fTemperature * fMoisture

#       relative management factor that reduces crop growth
        gass = gass * relmf

#       respiration and partitioning of carbohydrates between growth and maintenance respiration
        rmres = (rmr * cropYield[aDay-1].potential.roots.living +
                rml * cropYield[aDay-1].potential.leaves.living +
                rmo * cropYield[aDay-1].potential.storage.living +
                rms * cropYield[aDay-1].potential.stem.living) *
                interpolate(SenescenceReductionDvs,t)
        teff = q10^((aMeteo.aveTemp - 25.0) / 10.0)
        mres = min(gass, rmres * teff)
        asrc = gass - mres
#       println(t,"   ",asrc,"   ",gass,"   ",mres,"    ",rmres,"    ",teff)

#       partitioning factors
        dvs = cropYield[aDay].potential.dvs
        fr = interpolate(GrowthPartToRootsDvs, dvs)
        fl = interpolate(GrowthPartToLeavesDvs, dvs)
        fs = interpolate(GrowthPartToStemsDvs, dvs)
        fso = interpolate(GrowthPartToStorageDvs, dvs)
#       check on partitioning
        fcheck = fr + (fl + fs + fso) * (1.0 - fr) - 1.0
        if abs(fcheck) > 0.0001
          println("???ERROR in partitioning: sum=",fcheck)
        end

#       dry matter increase
        cvf = 1.0 / ((fl / cvl + fs / cvs + fso / cvo) * (1.0 - fr) +fr / cvr)
        dmi = cvf * asrc
#       println(dmi)
#       check on carbon balance
        ccheck = (gass - mres - (fr + (fl + fs + fso) * (1.0 - fr)) * dmi / cvf) / max(0.0001,gass)
        if abs(ccheck) > 0.0001
          println("???ERROR: The carbon balance is not correct")
        end

#       growth rate by plant organ

#       growth rate roots and aerial parts
#       after reaching a live weight of wrtmax(default 2500 kg), the
#       growth of the roots is balanced by the death of root tissue
        deathRateOfRoots = fTemperature * cropYield[aDay-1].potential.roots.living * interpolate(RelativeDeathRateOfRootsDvs,dvs)
        growthRateOfRoots = fr * dmi
        newWeight = cropYield[aDay-1].potential.roots.living + growthRateOfRoots - deathRateOfRoots
        if newWeight > maximumRootWeight
          growthRateOfRoots = max(0.0, growthRateOfRoots  - (newWeight - maximumRootWeight))
          deathRateOfRoots = max(0.0, cropYield[aDay-1].potential.roots.living + growthRateOfRoots - maximumRootWeight)
        end
#       println("gr=", growthRateOfRoots,"   dr=", deathRateOfRoots, "  living=", cropYield[aDay-1].potential.roots.living, "  dead=",cropYield[aDay-1].potential.roots.dead)

#       growth rate leaves
#       weight of new leaves
        admi = (1.0 - fr) * dmi
        growthRateLeaves = fl * admi

#       death of leaves due to water stress or high lai
        dslv1 = 0.0
        laicr = 3.2/kDif
        dslv2 = cropYield[aDay-1].potential.leaves.living * max(0.0, min(0.03,0.03 * (cropYield[aDay-1].potential.lai - laicr) / laicr))
        deathRateLeavesLai = max(dslv1, dslv2)

#       death of leaves due to exceeding life span;
#       leaf death is imposed on array until no more leaves have
#       to die or all leaves are gone

        deathRateLeavesAge = 0.0
        fysdel = max(0.0, (aMeteo.aveTemp - thresholdTempLeafAgeing)/(35.0 - thresholdTempLeafAgeing))
        for i in dayOfEmergence : aDay-1
          cropYield[i].potential.leaveAge += fysdel
          if cropYield[i].potential.leaveAge > maxAgeOfLeaves && cropYield[i].potential.leaves.living > 0.0
            if cropYield[i].dailyPotentialGrowth.leaves.living > 0.0
              deathRateLeavesAge += cropYield[i].dailyPotentialGrowth.leaves.living
              global cropYield[i].dailyPotentialGrowth.leaves.dead += cropYield[i].dailyPotentialGrowth.leaves.living
              global cropYield[i].dailyPotentialGrowth.leaves.living = 0.0
            end
          end
        end

#       leaf area not to exceed exponential growth curve
        glaiexp = 0.0
        slatpot = interpolate(SpecificLeafAreaDvs, dvs)
        if cropYield[aDay-1].potential.laiExp < 6.0
          dteff = max(0.0, aMeteo.aveTemp - thresholdTempLeafAgeing)
          glaiexp = cropYield[aDay-1].potential.laiExp * dteff * rgrlai
          glasol = growthRateLeaves * slatpot
          gla = min(glaiexp,glasol)
#         adjustment of specific leaf area of youngest leaf class
          if growthRateLeaves > 0.0
            slat = gla/growthRateLeaves
          end
        end

#       growth rate stems
        wst = cropYield[aDay-1].potential.stem.living
        growthRateStem = fs*admi
#       death of stems due to water stress is zero in case of potential growth
        deathRateStem1 = 0.0
#       death of stems due to ageing
        deathRateStem2 = interpolate(RelativeDeathRateOfStemsDvs, dvs) * wst
        deathRateStem = deathRateStem1 + deathRateStem2

#       growth rate storage organs
        growthRateStorage = fso * admi

#       lai in case of exponential growthRateStem
        global cropYield[aDay].potential.laiExp += glaiexp

#         integrals of the crop
#         dry weight of living plant organs
        global cropYield[aDay].dailyPotentialGrowth.leaves.living = growthRateLeaves - deathRateLeavesLai
        global cropYield[aDay].potential.leaves.living = max(0.0, cropYield[aDay-1].potential.leaves.living + growthRateLeaves - deathRateLeavesLai - deathRateLeavesAge)
        global cropYield[aDay].dailyPotentialGrowth.roots.living = growthRateOfRoots
        global cropYield[aDay].potential.roots.living = cropYield[aDay-1].potential.roots.living + growthRateOfRoots - deathRateOfRoots
        global cropYield[aDay].dailyPotentialGrowth.stem.living = growthRateStem - deathRateStem
        global cropYield[aDay].potential.stem.living = cropYield[aDay-1].potential.stem.living + growthRateStem - deathRateStem
        global cropYield[aDay].potential.storage.living = cropYield[aDay-1].potential.storage.living + growthRateStorage

#       dry weight of dead plant organs (roots,leaves & stems)
        global cropYield[aDay].dailyPotentialGrowth.roots.dead =  deathRateOfRoots
        global cropYield[aDay].potential.roots.dead = cropYield[aDay-1].potential.roots.dead + deathRateOfRoots
        global cropYield[aDay].potential.leaves.dead = cropYield[aDay-1].potential.leaves.dead + deathRateLeavesLai + deathRateLeavesAge
        global cropYield[aDay].dailyPotentialGrowth.stem.dead = deathRateStem
        global cropYield[aDay].potential.stem.dead = cropYield[aDay-1].potential.stem.dead + deathRateStem
        global cropYield[aDay].potential.storage.dead = 0.0

#       total
        global cropYield[aDay].potential.total.living = cropYield[aDay].potential.leaves.living + cropYield[aDay].potential.stem.living + cropYield[aDay].potential.storage.living
        global cropYield[aDay].potential.total.dead = cropYield[aDay].potential.leaves.dead + cropYield[aDay].potential.stem.dead

#       lai
        global cropYield[aDay].potential.lai = cropYield[aDay].potential.leaves.living * interpolate(SpecificLeafAreaDvs, cropYield[aDay].potential.dvs)

#        println(aDay, "   ", cropYield[aDay].potential.storage.living, "   ", cropYield[aDay].potential.lai)
      catch e
        println("???ERROR in Potato.potentialCropGrowth: ",e)
      end
    finally
    end
  end

  function moistureCropGrowth(aMeteo :: Main.Control.Types.Meteo, aDay :: Int64, aMoisture :: Float64)
    try
      try

        fMoisture = aMoisture
        fTemperature = 1.0

        t =convert(Float64, aDay)
        avrad = 1000.0 * aMeteo.radiation
        scv = 0.2

#       Declination and solar constant for this day
        declination = -asin(sind(23.45) * cos(2.0 * pi * (t+10) /365.0))
        solarConstant  = 1370.0 * (1.0 + 0.033 * cos(2.0*pi*t/365.0))

#       calculation of daylength from intermediate variables
#       SINLD, COSLD and AOB
        sinld = sind(latitude)*sin(declination)
        cosld = cosd(latitude)*cos(declination)
        aob = sinld/cosld

#       Calculate solution for base=0 degrees
        if abs(aob) <= 1.0
          daylength = 12.0 * (1.0 + 2.0 * asin(aob) / pi)
#         integrals of sine of solar height
          dsinb  = 3600.0 * (daylength * sinld + 24.0 * cosld * sqrt(1.0-aob*aob)/pi)
          dsinbe = 3600.0 * (daylength * (sinld + 0.40 * (sinld* sinld + cosld * cosld * 0.5)) + 12.0 * cosld * (2.0 + 3.0 * 0.4 * sinld) * sqrt(1.0 - aob * aob)/pi)
        else
          if aob > 1.0
             daylength = 24.0
          end
          if aob < 1.0
            daylength =  0.0
          end
#         integrals of sine of solar height
          dsinb  = 3600.0 * (daylength * sinld)
          dsinbe = 3600.0 * (daylength * (sinld + 0.4 * (sinld * sinld + cosld * cosld * 0.5)))
        end

#       Calculate solution for base =-4 (ANGLE) degrees
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

#       extraterrestrial radiation and atmospheric transmission
        angot  = solarConstant * dsinb
#       Check for daylength=0 as in that case the angot radiation is 0 as well
        atmtr = 0.0
        if daylength > 0.0
          atmtr = avrad / angot
        end

#       estimate fraction diffuse irradiation
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

        amax = interpolate(AssimilationRateDvs,cropYield[aDay].moisture.dvs) * interpolate(AmaxReductionAverageAirTemp, aMeteo.aveTemp)

#       potential growth
        dtga  = 0.0
        if amax > 0.0 && cropYield[aDay-1].moisture.lai > 0.0
          for i in 1:3
            hour = 12.0 + daylength * (Gauss3x[i] - 0.5)
            sinb = max(0.0, sinld + cosld *cos(2.0 * pi * (hour + 12.0) / 24.0))
            par = 0.5 * avrad * sinb * (1.0 + 0.4 * sinb) / dsinbe
            pardif = min(par, sinb * difpp)
            pardir = par - pardif

#           extinction coefficients kDif,kDirBL,kDirT, start of assim
            refh   = (1.0 - sqrt(1.0 - scv)) / (1.0 + sqrt(1.0 - scv))
            refs   = refh * 2.0 / (1.0 + 1.6 * sinb)
            kDirbl = (0.5 / sinb) * kDif / (0.8 * sqrt(1.0 - scv))
            kDirt  = kDirbl * sqrt(1.0 - scv)

#           three-point Gaussian integration over LAI
            fgros  = 0.0
            for j in 1:3
              laic   = cropYield[aDay-1].moisture.lai * Gauss3x[j]
#             absorbed diffuse radiation (VISDF),light from direct
#             origine (VIST) and direct light(VISD)
              visdf  = (1.0 - refs) * pardif * kDif * exp(-kDif * laic)
              vist   = (1.0 - refs) * pardir * kDirt * exp(-kDirt * laic)
              visd   = (1.0 - scv) * pardir * kDirbl * exp(-kDirbl*laic)
#             absorbed flux in W/m2 for shaded leaves and assimilation
              visshd = visdf + vist - visd
              fgrsh  = amax * (1.0 - exp(-visshd * eff / max(2.0,amax)))
#             direct light absorbed by leaves perpendicular on direct
#             beam and assimilation of sunlit leaf area
              vispp  = (1.0 - scv) * pardir / sinb
              fgrsun = fgrsh
              if vispp > 0.0
                fgrsun = amax * (1.0 - (amax - fgrsh) * (1.0-exp(-vispp * eff / max(2.0,amax))) / (eff * vispp))
              end
#             fraction of sunlit leaf area (FSLLA) and local assimilation rate (FGL)
              fslla  = exp(-kDirbl * laic)
              fgl    = fslla * fgrsun + (1.0 - fslla) * fgrsh
#             integration
              fgros  += fgl * Gauss3w[j]
            end
            fgros  *=  cropYield[aDay-1].moisture.lai
#           end of assim
            dtga += fgros * Gauss3w[i]
          end
          dtga = dtga * daylength
        end

#          println(dtga)
#          exit(0)

#       correction for low minimum temperature
        dtga *= interpolate(AmaxReductionMinAirTemp, aMeteo.minTemp)
#       potential assimilation in kg ch2o per ha
        pgass = dtga * 30.0 / 44.0

#       water stress reduction of pgass to gass and limited attainable maximum
        gass = pgass * fTemperature * fMoisture

#       relative management factor that reduces crop growth
        gass = gass * relmf

#       respiration and partitioning of carbohydrates between growth and maintenance respiration
        rmres = (rmr * cropYield[aDay-1].moisture.roots.living +
                rml * cropYield[aDay-1].moisture.leaves.living +
                rmo * cropYield[aDay-1].moisture.storage.living +
                rms * cropYield[aDay-1].moisture.stem.living) *
                interpolate(SenescenceReductionDvs,t)
        teff = q10^((aMeteo.aveTemp - 25.0) / 10.0)
        mres = min(gass, rmres * teff)
        asrc = gass - mres
#       println(t,"   ",asrc,"   ",gass,"   ",mres,"    ",rmres,"    ",teff)

#       partitioning factors
        dvs = cropYield[aDay].moisture.dvs
        fr = interpolate(GrowthPartToRootsDvs, dvs)
        fl = interpolate(GrowthPartToLeavesDvs, dvs)
        fs = interpolate(GrowthPartToStemsDvs, dvs)
        fso = interpolate(GrowthPartToStorageDvs, dvs)
#       check on partitioning
        fcheck = fr + (fl + fs + fso) * (1.0 - fr) - 1.0
        if abs(fcheck) > 0.0001
          println("???ERROR in partitioning: sum=",fcheck)
        end

#       dry matter increase
        cvf = 1.0 / ((fl / cvl + fs / cvs + fso / cvo) * (1.0 - fr) +fr / cvr)
        dmi = cvf * asrc
#       println(dmi)
#       check on carbon balance
        ccheck = (gass - mres - (fr + (fl + fs + fso) * (1.0 - fr)) * dmi / cvf) / max(0.0001,gass)
        if abs(ccheck) > 0.0001
          println("???ERROR: The carbon balance is not correct")
        end

#       growth rate by plant organ

#       growth rate roots and aerial parts
#       after reaching a live weight of wrtmax(default 2500 kg), the
#       growth of the roots is balanced by the death of root tissue
        deathRateOfRoots = fTemperature * cropYield[aDay-1].moisture.roots.living * interpolate(RelativeDeathRateOfRootsDvs,dvs)
        growthRateOfRoots = fr * dmi
        newWeight = cropYield[aDay-1].moisture.roots.living + growthRateOfRoots - deathRateOfRoots
        if newWeight > maximumRootWeight
          growthRateOfRoots = max(0.0, growthRateOfRoots  - (newWeight - maximumRootWeight))
          deathRateOfRoots = max(0.0, cropYield[aDay-1].moisture.roots.living + growthRateOfRoots - maximumRootWeight)
        end
#       println("gr=", growthRateOfRoots,"   dr=", deathRateOfRoots, "  living=", cropYield[aDay-1].moisture.roots.living, "  dead=",cropYield[aDay-1].moisture.roots.dead)

#       growth rate leaves
#       weight of new leaves
        admi = (1.0 - fr) * dmi
        growthRateLeaves = fl * admi

#       death of leaves due to water stress or high lai
        dslv1 = growthRateLeaves * fTemperature * (1.0 - fMoisture) * RelativeDeathRateOfLeavesByWaterStress
        laicr = 3.2/kDif
        dslv2 = cropYield[aDay-1].moisture.leaves.living * max(0.0, min(0.03,0.03 * (cropYield[aDay-1].moisture.lai - laicr) / laicr))
        deathRateLeavesLai = max(dslv1, dslv2)

#       death of leaves due to exceeding life span;
#       leaf death is imposed on array until no more leaves have
#       to die or all leaves are gone

        deathRateLeavesAge = 0.0
        fysdel = max(0.0, (aMeteo.aveTemp - thresholdTempLeafAgeing)/(35.0 - thresholdTempLeafAgeing))
        for i in dayOfEmergence : aDay-1
          cropYield[i].moisture.leaveAge += fysdel
          if cropYield[i].moisture.leaveAge > maxAgeOfLeaves && cropYield[i].moisture.leaves.living > 0.0
            if cropYield[i].dailyMoistureGrowth.leaves.living > 0.0
              deathRateLeavesAge += cropYield[i].dailyMoistureGrowth.leaves.living
              global cropYield[i].dailyMoistureGrowth.leaves.dead += cropYield[i].dailyMoistureGrowth.leaves.living
              global cropYield[i].dailyMoistureGrowth.leaves.living = 0.0
            end
          end
        end

#       leaf area not to exceed exponential growth curve
        glaiexp = 0.0
        slatpot = interpolate(SpecificLeafAreaDvs, dvs)
        if cropYield[aDay-1].moisture.laiExp < 6.0
          dteff = max(0.0, aMeteo.aveTemp - thresholdTempLeafAgeing)
          glaiexp = cropYield[aDay-1].moisture.laiExp * dteff * rgrlai
          glasol = growthRateLeaves * slatpot
          gla = min(glaiexp,glasol)
#         adjustment of specific leaf area of youngest leaf class
          if growthRateLeaves > 0.0
            slat = gla/growthRateLeaves
          end
        end

#       growth rate stems
        wst = cropYield[aDay-1].moisture.stem.living
        growthRateStem = fs*admi
#       death of stems due to water stress
        deathRateStem1 = growthRateStem * fTemperature * (1.0 - fMoisture) * RelativeDeathRateOfLeavesByWaterStress
#       death of stems due to ageing
        deathRateStem2 = interpolate(RelativeDeathRateOfStemsDvs, dvs) * wst
        deathRateStem = deathRateStem1 + deathRateStem2

#       growth rate storage organs
        growthRateStorage = fso * admi

#       lai in case of exponential growthRateStem
        global cropYield[aDay].moisture.laiExp += glaiexp

#         integrals of the crop
#         dry weight of living plant organs
        global cropYield[aDay].dailyMoistureGrowth.leaves.living = growthRateLeaves - deathRateLeavesLai
        global cropYield[aDay].moisture.leaves.living = max(0.0, cropYield[aDay-1].moisture.leaves.living + growthRateLeaves - deathRateLeavesLai - deathRateLeavesAge)
        global cropYield[aDay].dailyMoistureGrowth.roots.living = growthRateOfRoots
        global cropYield[aDay].moisture.roots.living = cropYield[aDay-1].moisture.roots.living + growthRateOfRoots - deathRateOfRoots
        global cropYield[aDay].dailyMoistureGrowth.stem.living = growthRateStem - deathRateStem
        global cropYield[aDay].moisture.stem.living = cropYield[aDay-1].moisture.stem.living + growthRateStem - deathRateStem
        global cropYield[aDay].moisture.storage.living = cropYield[aDay-1].moisture.storage.living + growthRateStorage

#       dry weight of dead plant organs (roots,leaves & stems)
        global cropYield[aDay].dailyMoistureGrowth.roots.dead =  deathRateOfRoots
        global cropYield[aDay].moisture.roots.dead = cropYield[aDay-1].moisture.roots.dead + deathRateOfRoots
        global cropYield[aDay].moisture.leaves.dead = cropYield[aDay-1].moisture.leaves.dead + deathRateLeavesLai + deathRateLeavesAge
        global cropYield[aDay].dailyMoistureGrowth.stem.dead = deathRateStem
        global cropYield[aDay].moisture.stem.dead = cropYield[aDay-1].moisture.stem.dead + deathRateStem
        global cropYield[aDay].moisture.storage.dead = 0.0

#       total
        global cropYield[aDay].moisture.total.living = cropYield[aDay].moisture.leaves.living + cropYield[aDay].moisture.stem.living + cropYield[aDay].moisture.storage.living
        global cropYield[aDay].moisture.total.dead = cropYield[aDay].moisture.leaves.dead + cropYield[aDay].moisture.stem.dead

#       lai
        global cropYield[aDay].moisture.lai = cropYield[aDay].moisture.leaves.living * interpolate(SpecificLeafAreaDvs, cropYield[aDay].moisture.dvs)

#        println(aDay, "   ", cropYield[aDay].moisture.storage.living, "   ", cropYield[aDay].moisture.lai)
      catch e
        println("???ERROR in moistureCropGrowth: ",e)
      end
    finally
    end
  end

    function temperatureCropGrowth(aMeteo :: Main.Control.Types.Meteo, aDay :: Int64, aTemperature :: Float64)
      try
        try

          fMoisture = 1.0
          fTemperature = aTemperature

          t =convert(Float64, aDay)
          avrad = 1000.0 * aMeteo.radiation
          scv = 0.2

  #       Declination and solar constant for this day
          declination = -asin(sind(23.45) * cos(2.0 * pi * (t+10) /365.0))
          solarConstant  = 1370.0 * (1.0 + 0.033 * cos(2.0*pi*t/365.0))

  #       calculation of daylength from intermediate variables
  #       SINLD, COSLD and AOB
          sinld = sind(latitude)*sin(declination)
          cosld = cosd(latitude)*cos(declination)
          aob = sinld/cosld

  #       Calculate solution for base=0 degrees
          if abs(aob) <= 1.0
            daylength = 12.0 * (1.0 + 2.0 * asin(aob) / pi)
  #         integrals of sine of solar height
            dsinb  = 3600.0 * (daylength * sinld + 24.0 * cosld * sqrt(1.0-aob*aob)/pi)
            dsinbe = 3600.0 * (daylength * (sinld + 0.40 * (sinld* sinld + cosld * cosld * 0.5)) + 12.0 * cosld * (2.0 + 3.0 * 0.4 * sinld) * sqrt(1.0 - aob * aob)/pi)
          else
            if aob > 1.0
               daylength = 24.0
            end
            if aob < 1.0
              daylength =  0.0
            end
  #         integrals of sine of solar height
            dsinb  = 3600.0 * (daylength * sinld)
            dsinbe = 3600.0 * (daylength * (sinld + 0.4 * (sinld * sinld + cosld * cosld * 0.5)))
          end

  #       Calculate solution for base =-4 (ANGLE) degrees
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

  #       extraterrestrial radiation and atmospheric transmission
          angot  = solarConstant * dsinb
  #       Check for daylength=0 as in that case the angot radiation is 0 as well
          atmtr = 0.0
          if daylength > 0.0
            atmtr = avrad / angot
          end

  #       estimate fraction diffuse irradiation
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

          amax = interpolate(AssimilationRateDvs,cropYield[aDay].temperature.dvs) * interpolate(AmaxReductionAverageAirTemp, aMeteo.aveTemp)

  #       potential growth
          dtga  = 0.0
          if amax > 0.0 && cropYield[aDay-1].temperature.lai > 0.0
            for i in 1:3
              hour = 12.0 + daylength * (Gauss3x[i] - 0.5)
              sinb = max(0.0, sinld + cosld *cos(2.0 * pi * (hour + 12.0) / 24.0))
              par = 0.5 * avrad * sinb * (1.0 + 0.4 * sinb) / dsinbe
              pardif = min(par, sinb * difpp)
              pardir = par - pardif

  #           extinction coefficients kDif,kDirBL,kDirT, start of assim
              refh   = (1.0 - sqrt(1.0 - scv)) / (1.0 + sqrt(1.0 - scv))
              refs   = refh * 2.0 / (1.0 + 1.6 * sinb)
              kDirbl = (0.5 / sinb) * kDif / (0.8 * sqrt(1.0 - scv))
              kDirt  = kDirbl * sqrt(1.0 - scv)

  #           three-point Gaussian integration over LAI
              fgros  = 0.0
              for j in 1:3
                laic   = cropYield[aDay-1].potential.lai * Gauss3x[j]
  #             absorbed diffuse radiation (VISDF),light from direct
  #             origine (VIST) and direct light(VISD)
                visdf  = (1.0 - refs) * pardif * kDif * exp(-kDif * laic)
                vist   = (1.0 - refs) * pardir * kDirt * exp(-kDirt * laic)
                visd   = (1.0 - scv) * pardir * kDirbl * exp(-kDirbl*laic)
  #             absorbed flux in W/m2 for shaded leaves and assimilation
                visshd = visdf + vist - visd
                fgrsh  = amax * (1.0 - exp(-visshd * eff / max(2.0,amax)))
  #             direct light absorbed by leaves perpendicular on direct
  #             beam and assimilation of sunlit leaf area
                vispp  = (1.0 - scv) * pardir / sinb
                fgrsun = fgrsh
                if vispp > 0.0
                  fgrsun = amax * (1.0 - (amax - fgrsh) * (1.0-exp(-vispp * eff / max(2.0,amax))) / (eff * vispp))
                end
  #             fraction of sunlit leaf area (FSLLA) and local assimilation rate (FGL)
                fslla  = exp(-kDirbl * laic)
                fgl    = fslla * fgrsun + (1.0 - fslla) * fgrsh
  #             integration
                fgros  += fgl * Gauss3w[j]
              end
              fgros  *=  cropYield[aDay-1].temperature.lai
  #           end of assim
              dtga += fgros * Gauss3w[i]
            end
            dtga = dtga * daylength
          end

  #          println(dtga)
  #          exit(0)

  #       correction for low minimum temperature
          dtga *= interpolate(AmaxReductionMinAirTemp, aMeteo.minTemp)
  #       potential assimilation in kg ch2o per ha
          pgass = dtga * 30.0 / 44.0

  #       water stress reduction of pgass to gass and limited attainable maximum
          gass = pgass * fTemperature * fMoisture

  #       relative management factor that reduces crop growth
          gass = gass * relmf

  #       respiration and partitioning of carbohydrates between growth and maintenance respiration
          rmres = (rmr * cropYield[aDay-1].temperature.roots.living +
                  rml * cropYield[aDay-1].temperature.leaves.living +
                  rmo * cropYield[aDay-1].temperature.storage.living +
                  rms * cropYield[aDay-1].temperature.stem.living) *
                  interpolate(SenescenceReductionDvs,t)
          teff = q10^((aMeteo.aveTemp - 25.0) / 10.0)
          mres = min(gass, rmres * teff)
          asrc = gass - mres
  #       println(t,"   ",asrc,"   ",gass,"   ",mres,"    ",rmres,"    ",teff)

  #       partitioning factors
          dvs = cropYield[aDay].temperature.dvs
          fr = interpolate(GrowthPartToRootsDvs, dvs)
          fl = interpolate(GrowthPartToLeavesDvs, dvs)
          fs = interpolate(GrowthPartToStemsDvs, dvs)
          fso = interpolate(GrowthPartToStorageDvs, dvs)
  #       check on partitioning
          fcheck = fr + (fl + fs + fso) * (1.0 - fr) - 1.0
          if abs(fcheck) > 0.0001
            println("???ERROR in partitioning: sum=",fcheck)
          end

  #       dry matter increase
          cvf = 1.0 / ((fl / cvl + fs / cvs + fso / cvo) * (1.0 - fr) +fr / cvr)
          dmi = cvf * asrc
  #       println(dmi)
  #       check on carbon balance
          ccheck = (gass - mres - (fr + (fl + fs + fso) * (1.0 - fr)) * dmi / cvf) / max(0.0001,gass)
          if abs(ccheck) > 0.0001
            println("???ERROR: The carbon balance is not correct")
          end

  #       growth rate by plant organ

  #       growth rate roots and aerial parts
  #       after reaching a live weight of wrtmax(default 2500 kg), the
  #       growth of the roots is balanced by the death of root tissue
          deathRateOfRoots = fTemperature * cropYield[aDay-1].temperature.roots.living * interpolate(RelativeDeathRateOfRootsDvs,dvs)
          growthRateOfRoots = fr * dmi
          newWeight = cropYield[aDay-1].temperature.roots.living + growthRateOfRoots - deathRateOfRoots
          if newWeight > maximumRootWeight
            growthRateOfRoots = max(0.0, growthRateOfRoots  - (newWeight - maximumRootWeight))
            deathRateOfRoots = max(0.0, cropYield[aDay-1].temperature.roots.living + growthRateOfRoots - maximumRootWeight)
          end
  #       println("gr=", growthRateOfRoots,"   dr=", deathRateOfRoots, "  living=", cropYield[aDay-1].temperature.roots.living, "  dead=",cropYield[aDay-1].temperature.roots.dead)

  #       growth rate leaves
  #       weight of new leaves
          admi = (1.0 - fr) * dmi
          growthRateLeaves = fl * admi

  #       death of leaves due to water stress or high lai
          dslv1 = growthRateLeaves * fTemperature * (1.0 - fMoisture) * RelativeDeathRateOfLeavesByWaterStress
          laicr = 3.2/kDif
          dslv2 = cropYield[aDay-1].temperature.leaves.living * max(0.0, min(0.03,0.03 * (cropYield[aDay-1].temperature.lai - laicr) / laicr))
          deathRateLeavesLai = max(dslv1, dslv2)

  #       death of leaves due to exceeding life span;
  #       leaf death is imposed on array until no more leaves have
  #       to die or all leaves are gone

          deathRateLeavesAge = 0.0
          fysdel = max(0.0, (aMeteo.aveTemp - thresholdTempLeafAgeing)/(35.0 - thresholdTempLeafAgeing))
          for i in dayOfEmergence : aDay-1
            cropYield[i].temperature.leaveAge += fysdel
            if cropYield[i].temperature.leaveAge > maxAgeOfLeaves && cropYield[i].temperature.leaves.living > 0.0
              if cropYield[i].dailyTemperatureGrowth.leaves.living > 0.0
                deathRateLeavesAge += cropYield[i].dailyTemperatureGrowth.leaves.living
                global cropYield[i].dailyTemperatureGrowth.leaves.dead += cropYield[i].dailyTemperatureGrowth.leaves.living
                global cropYield[i].dailyTemperatureGrowth.leaves.living = 0.0
              end
            end
          end

  #       leaf area not to exceed exponential growth curve
          glaiexp = 0.0
          slatpot = interpolate(SpecificLeafAreaDvs, dvs)
          if cropYield[aDay-1].temperature.laiExp < 6.0
            dteff = max(0.0, aMeteo.aveTemp - thresholdTempLeafAgeing)
            glaiexp = cropYield[aDay-1].temperature.laiExp * dteff * rgrlai
            glasol = growthRateLeaves * slatpot
            gla = min(glaiexp,glasol)
  #         adjustment of specific leaf area of youngest leaf class
            if growthRateLeaves > 0.0
              slat = gla/growthRateLeaves
            end
          end

  #       growth rate stems
          wst = cropYield[aDay-1].temperature.stem.living
          growthRateStem = fs*admi
  #       death of stems due to water stress
          deathRateStem1 = growthRateStem * fTemperature * (1.0 - fTemperature) * RelativeDeathRateOfLeavesByWaterStress
  #       death of stems due to ageing
          deathRateStem2 = interpolate(RelativeDeathRateOfStemsDvs, dvs) * wst
          deathRateStem = deathRateStem1 + deathRateStem2

  #       growth rate storage organs
          growthRateStorage = fso * admi

  #       lai in case of exponential growthRateStem
          global cropYield[aDay].temperature.laiExp += glaiexp

  #         integrals of the crop
  #         dry weight of living plant organs
          global cropYield[aDay].dailyTemperatureGrowth.leaves.living = growthRateLeaves - deathRateLeavesLai
          global cropYield[aDay].temperature.leaves.living = max(0.0, cropYield[aDay-1].temperature.leaves.living + growthRateLeaves - deathRateLeavesLai - deathRateLeavesAge)
          global cropYield[aDay].dailyTemperatureGrowth.roots.living = growthRateOfRoots
          global cropYield[aDay].temperature.roots.living = cropYield[aDay-1].temperature.roots.living + growthRateOfRoots - deathRateOfRoots
          global cropYield[aDay].dailyTemperatureGrowth.stem.living = growthRateStem - deathRateStem
          global cropYield[aDay].temperature.stem.living = cropYield[aDay-1].temperature.stem.living + growthRateStem - deathRateStem
          global cropYield[aDay].temperature.storage.living = cropYield[aDay-1].temperature.storage.living + growthRateStorage

  #       dry weight of dead plant organs (roots,leaves & stems)
          global cropYield[aDay].dailyTemperatureGrowth.roots.dead =  deathRateOfRoots
          global cropYield[aDay].temperature.roots.dead = cropYield[aDay-1].temperature.roots.dead + deathRateOfRoots
          global cropYield[aDay].temperature.leaves.dead = cropYield[aDay-1].temperature.leaves.dead + deathRateLeavesLai + deathRateLeavesAge
          global cropYield[aDay].dailyTemperatureGrowth.stem.dead = deathRateStem
          global cropYield[aDay].temperature.stem.dead = cropYield[aDay-1].temperature.stem.dead + deathRateStem
          global cropYield[aDay].temperature.storage.dead = 0.0

  #       total
          global cropYield[aDay].temperature.total.living = cropYield[aDay].temperature.leaves.living + cropYield[aDay].temperature.stem.living + cropYield[aDay].temperature.storage.living
          global cropYield[aDay].temperature.total.dead = cropYield[aDay].temperature.leaves.dead + cropYield[aDay].temperature.stem.dead

  #       lai
          global cropYield[aDay].temperature.lai = cropYield[aDay].temperature.leaves.living * interpolate(SpecificLeafAreaDvs, cropYield[aDay].temperature.dvs)

  #        println(aDay, "   ", cropYield[aDay].temperature.storage.living, "   ", cropYield[aDay].temperature.lai)
        catch e
          println("???ERROR in temperatureCropGrowth: ",e)
        end
      finally
      end
    end

    function actualCropGrowth(aMeteo :: Main.Control.Types.Meteo, aDay :: Int64, aMoisture :: Float64, aTemperature :: Float64)
      try
        try

          fMoisture = aMoisture
          fTemperature = aTemperature

          t =convert(Float64, aDay)
          avrad = 1000.0 * aMeteo.radiation
          scv = 0.2

  #       Declination and solar constant for this day
          declination = -asin(sind(23.45) * cos(2.0 * pi * (t+10) /365.0))
          solarConstant  = 1370.0 * (1.0 + 0.033 * cos(2.0*pi*t/365.0))

  #       calculation of daylength from intermediate variables
  #       SINLD, COSLD and AOB
          sinld = sind(latitude)*sin(declination)
          cosld = cosd(latitude)*cos(declination)
          aob = sinld/cosld

  #       Calculate solution for base=0 degrees
          if abs(aob) <= 1.0
            daylength = 12.0 * (1.0 + 2.0 * asin(aob) / pi)
  #         integrals of sine of solar height
            dsinb  = 3600.0 * (daylength * sinld + 24.0 * cosld * sqrt(1.0-aob*aob)/pi)
            dsinbe = 3600.0 * (daylength * (sinld + 0.40 * (sinld* sinld + cosld * cosld * 0.5)) + 12.0 * cosld * (2.0 + 3.0 * 0.4 * sinld) * sqrt(1.0 - aob * aob)/pi)
          else
            if aob > 1.0
               daylength = 24.0
            end
            if aob < 1.0
              daylength =  0.0
            end
  #         integrals of sine of solar height
            dsinb  = 3600.0 * (daylength * sinld)
            dsinbe = 3600.0 * (daylength * (sinld + 0.4 * (sinld * sinld + cosld * cosld * 0.5)))
          end

  #       Calculate solution for base =-4 (ANGLE) degrees
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

  #       extraterrestrial radiation and atmospheric transmission
          angot  = solarConstant * dsinb
  #       Check for daylength=0 as in that case the angot radiation is 0 as well
          atmtr = 0.0
          if daylength > 0.0
            atmtr = avrad / angot
          end

  #       estimate fraction diffuse irradiation
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

          amax = interpolate(AssimilationRateDvs,cropYield[aDay].actual.dvs) * interpolate(AmaxReductionAverageAirTemp, aMeteo.aveTemp)

  #       potential growth
          dtga  = 0.0
          if amax > 0.0 && cropYield[aDay-1].actual.lai > 0.0
            for i in 1:3
              hour = 12.0 + daylength * (Gauss3x[i] - 0.5)
              sinb = max(0.0, sinld + cosld *cos(2.0 * pi * (hour + 12.0) / 24.0))
              par = 0.5 * avrad * sinb * (1.0 + 0.4 * sinb) / dsinbe
              pardif = min(par, sinb * difpp)
              pardir = par - pardif

  #           extinction coefficients kDif,kDirBL,kDirT, start of assim
              refh   = (1.0 - sqrt(1.0 - scv)) / (1.0 + sqrt(1.0 - scv))
              refs   = refh * 2.0 / (1.0 + 1.6 * sinb)
              kDirbl = (0.5 / sinb) * kDif / (0.8 * sqrt(1.0 - scv))
              kDirt  = kDirbl * sqrt(1.0 - scv)

  #           three-point Gaussian integration over LAI
              fgros  = 0.0
              for j in 1:3
                laic   = cropYield[aDay-1].potential.lai * Gauss3x[j]
  #             absorbed diffuse radiation (VISDF),light from direct
  #             origine (VIST) and direct light(VISD)
                visdf  = (1.0 - refs) * pardif * kDif * exp(-kDif * laic)
                vist   = (1.0 - refs) * pardir * kDirt * exp(-kDirt * laic)
                visd   = (1.0 - scv) * pardir * kDirbl * exp(-kDirbl*laic)
  #             absorbed flux in W/m2 for shaded leaves and assimilation
                visshd = visdf + vist - visd
                fgrsh  = amax * (1.0 - exp(-visshd * eff / max(2.0,amax)))
  #             direct light absorbed by leaves perpendicular on direct
  #             beam and assimilation of sunlit leaf area
                vispp  = (1.0 - scv) * pardir / sinb
                fgrsun = fgrsh
                if vispp > 0.0
                  fgrsun = amax * (1.0 - (amax - fgrsh) * (1.0-exp(-vispp * eff / max(2.0,amax))) / (eff * vispp))
                end
  #             fraction of sunlit leaf area (FSLLA) and local assimilation rate (FGL)
                fslla  = exp(-kDirbl * laic)
                fgl    = fslla * fgrsun + (1.0 - fslla) * fgrsh
  #             integration
                fgros  += fgl * Gauss3w[j]
              end
              fgros  *=  cropYield[aDay-1].actual.lai
  #           end of assim
              dtga += fgros * Gauss3w[i]
            end
            dtga = dtga * daylength
          end

  #          println(dtga)
  #          exit(0)

  #       correction for low minimum temperature
          dtga *= interpolate(AmaxReductionMinAirTemp, aMeteo.minTemp)
  #       potential assimilation in kg ch2o per ha
          pgass = dtga * 30.0 / 44.0

  #       water stress reduction of pgass to gass and limited attainable maximum
          gass = pgass * fTemperature * fMoisture

  #       relative management factor that reduces crop growth
          gass = gass * relmf

  #       respiration and partitioning of carbohydrates between growth and maintenance respiration
          rmres = (rmr * cropYield[aDay-1].actual.roots.living +
                  rml * cropYield[aDay-1].actual.leaves.living +
                  rmo * cropYield[aDay-1].actual.storage.living +
                  rms * cropYield[aDay-1].actual.stem.living) *
                  interpolate(SenescenceReductionDvs,t)
          teff = q10^((aMeteo.aveTemp - 25.0) / 10.0)
          mres = min(gass, rmres * teff)
          asrc = gass - mres
  #       println(t,"   ",asrc,"   ",gass,"   ",mres,"    ",rmres,"    ",teff)

  #       partitioning factors
          dvs = cropYield[aDay].actual.dvs
          fr = interpolate(GrowthPartToRootsDvs, dvs)
          fl = interpolate(GrowthPartToLeavesDvs, dvs)
          fs = interpolate(GrowthPartToStemsDvs, dvs)
          fso = interpolate(GrowthPartToStorageDvs, dvs)
  #       check on partitioning
          fcheck = fr + (fl + fs + fso) * (1.0 - fr) - 1.0
          if abs(fcheck) > 0.0001
            println("???ERROR in partitioning: sum=",fcheck)
          end

  #       dry matter increase
          cvf = 1.0 / ((fl / cvl + fs / cvs + fso / cvo) * (1.0 - fr) +fr / cvr)
          dmi = cvf * asrc
  #       println(dmi)
  #       check on carbon balance
          ccheck = (gass - mres - (fr + (fl + fs + fso) * (1.0 - fr)) * dmi / cvf) / max(0.0001,gass)
          if abs(ccheck) > 0.0001
            println("???ERROR: The carbon balance is not correct")
          end

  #       growth rate by plant organ

  #       growth rate roots and aerial parts
  #       after reaching a live weight of wrtmax(default 2500 kg), the
  #       growth of the roots is balanced by the death of root tissue
          deathRateOfRoots = fTemperature * cropYield[aDay-1].actual.roots.living * interpolate(RelativeDeathRateOfRootsDvs,dvs)
          growthRateOfRoots = fr * dmi
          newWeight = cropYield[aDay-1].actual.roots.living + growthRateOfRoots - deathRateOfRoots
          if newWeight > maximumRootWeight
            growthRateOfRoots = max(0.0, growthRateOfRoots  - (newWeight - maximumRootWeight))
            deathRateOfRoots = max(0.0, cropYield[aDay-1].actual.roots.living + growthRateOfRoots - maximumRootWeight)
          end
  #       println("gr=", growthRateOfRoots,"   dr=", deathRateOfRoots, "  living=", cropYield[aDay-1].actual.roots.living, "  dead=",cropYield[aDay-1].actual.roots.dead)

  #       growth rate leaves
  #       weight of new leaves
          admi = (1.0 - fr) * dmi
          growthRateLeaves = fl * admi

  #       death of leaves due to water stress or high lai
          dslv1 = growthRateLeaves * (1.0 - fMoisture) * RelativeDeathRateOfLeavesByWaterStress
          laicr = 3.2/kDif
          dslv2 = cropYield[aDay-1].actual.leaves.living * max(0.0, min(0.03,0.03 * (cropYield[aDay-1].actual.lai - laicr) / laicr))
          dslv3 = growthRateLeaves * abs(1.0 - fTemperature) * RelativeDeathRateOfLeavesByWaterStress
          deathRateLeavesLai = max(dslv1, dslv2, dslv3)

  #       death of leaves due to exceeding life span;
  #       leaf death is imposed on array until no more leaves have
  #       to die or all leaves are gone

          deathRateLeavesAge = 0.0
          fysdel = max(0.0, (aMeteo.aveTemp - thresholdTempLeafAgeing)/(35.0 - thresholdTempLeafAgeing))
          for i in dayOfEmergence : aDay-1
            cropYield[i].actual.leaveAge += fysdel
            if cropYield[i].actual.leaveAge > maxAgeOfLeaves && cropYield[i].actual.leaves.living > 0.0
              if cropYield[i].dailyActualGrowth.leaves.living > 0.0
                deathRateLeavesAge += cropYield[i].dailyActualGrowth.leaves.living
                global cropYield[i].dailyActualGrowth.leaves.dead += cropYield[i].dailyActualGrowth.leaves.living
                global cropYield[i].dailyActualGrowth.leaves.living = 0.0
              end
            end
          end

  #       leaf area not to exceed exponential growth curve
          glaiexp = 0.0
          slatpot = interpolate(SpecificLeafAreaDvs, dvs)
          if cropYield[aDay-1].actual.laiExp < 6.0
            dteff = max(0.0, aMeteo.aveTemp - thresholdTempLeafAgeing)
            glaiexp = cropYield[aDay-1].actual.laiExp * dteff * rgrlai
            glasol = growthRateLeaves * slatpot
            gla = min(glaiexp,glasol)
  #         adjustment of specific leaf area of youngest leaf class
            if growthRateLeaves > 0.0
              slat = gla/growthRateLeaves
            end
          end

  #       growth rate stems
          wst = cropYield[aDay-1].actual.stem.living
          growthRateStem = fs*admi
  #       death of stems due to water stress
          deathRateStem1 = growthRateStem * fTemperature * (1.0 - fTemperature) * RelativeDeathRateOfLeavesByWaterStress
  #       death of stems due to ageing
          deathRateStem2 = interpolate(RelativeDeathRateOfStemsDvs, dvs) * wst
          deathRateStem = deathRateStem1 + deathRateStem2

  #       growth rate storage organs
          growthRateStorage = fso * admi

  #       lai in case of exponential growthRateStem
          global cropYield[aDay].actual.laiExp += glaiexp

  #         integrals of the crop
  #         dry weight of living plant organs
          global cropYield[aDay].dailyActualGrowth.leaves.living = growthRateLeaves - deathRateLeavesLai
          global cropYield[aDay].actual.leaves.living = max(0.0, cropYield[aDay-1].actual.leaves.living + growthRateLeaves - deathRateLeavesLai - deathRateLeavesAge)
          global cropYield[aDay].dailyActualGrowth.roots.living = growthRateOfRoots
          global cropYield[aDay].actual.roots.living = cropYield[aDay-1].actual.roots.living + growthRateOfRoots - deathRateOfRoots
          global cropYield[aDay].dailyActualGrowth.stem.living = growthRateStem - deathRateStem
          global cropYield[aDay].actual.stem.living = cropYield[aDay-1].actual.stem.living + growthRateStem - deathRateStem
          global cropYield[aDay].actual.storage.living = cropYield[aDay-1].actual.storage.living + growthRateStorage

  #       dry weight of dead plant organs (roots,leaves & stems)
          global cropYield[aDay].dailyActualGrowth.roots.dead =  deathRateOfRoots
          global cropYield[aDay].actual.roots.dead = cropYield[aDay-1].actual.roots.dead + deathRateOfRoots
          global cropYield[aDay].actual.leaves.dead = cropYield[aDay-1].actual.leaves.dead + deathRateLeavesLai + deathRateLeavesAge
          global cropYield[aDay].dailyActualGrowth.stem.dead = deathRateStem
          global cropYield[aDay].actual.stem.dead = cropYield[aDay-1].actual.stem.dead + deathRateStem
          global cropYield[aDay].actual.storage.dead = 0.0

  #       total
          global cropYield[aDay].actual.total.living = cropYield[aDay].actual.leaves.living + cropYield[aDay].actual.stem.living + cropYield[aDay].actual.storage.living
          global cropYield[aDay].actual.total.dead = cropYield[aDay].actual.leaves.dead + cropYield[aDay].actual.stem.dead

  #       lai
          global cropYield[aDay].actual.lai = cropYield[aDay].actual.leaves.living * interpolate(SpecificLeafAreaDvs, cropYield[aDay].actual.dvs)

  #        println(aDay, "   ", cropYield[aDay].actual.storage.living, "   ", cropYield[aDay].actual.lai)
        catch e
          println("???ERROR in actualCropGrowth: ",e)
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
        println("???ERROR in Potato.moistureFactor: ",e)
      end
    finally
    end
    return fMoisture
  end

  function temperatureFactorAmax(aMeteo :: Main.Control.Types.Meteo, aDepth :: Float64, aDvs :: Float64)
    fTemperature = 0.0
    try
      try
        dz = -1.0 * sensorDepth[1]
        node = 1
        temp = simulatedTemperature[aMeteo.dayofyear, (position-1) * size(sensorDepth,1) + node + 1]
        if aDvs < 1.0
          fTemperature += dz * interpolate(AmaxFactorSoilTemperature1, temp)
        else
          fTemperature += dz * interpolate(AmaxFactorSoilTemperature2, temp)
        end

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
            if aDvs < 1.0
              fTemperature += dz * interpolate(AmaxFactorSoilTemperature1, temp)
            else
              fTemperature += dz * interpolate(AmaxFactorSoilTemperature2, temp)
            end
          end
        end
        fTemperature = fTemperature / abs(aDepth)
#        println(aDepth, "   ", temp, "   ", fTemperature)
#        exit(0)
      catch e
        println("???ERROR in Potato.temperatureFactorAmax: ",e)
      end
    finally
    end
    return fTemperature
  end

  function temperatureFactorDvs(aMeteo :: Main.Control.Types.Meteo, aDepth :: Float64, aDvs :: Float64)
    fTemperature = 0.0
    try
      try
        node = 1
        temp = -1.0
        dz = -1.0 * sensorDepth[1]
        node = 1
        temp = simulatedTemperature[aMeteo.dayofyear, (position-1) * size(sensorDepth,1) + node + 1]
        if aDvs < 1.0
          fTemperature += dz * interpolate(DvsFactorSoilTemperature1, temp)
        else
          fTemperature += dz * interpolate(DvsFactorSoilTemperature2, temp)
        end

        if aDepth < sensorDepth[1]
          while node < size(sensorDepth,1)
            node += 1
            dz = sensorDepth[node-1] - sensorDepth[node]
            temp = 0.5 * (simulatedTemperature[aMeteo.dayofyear, (position-1) * size(sensorDepth,1) + node] + simulatedTemperature[aMeteo.dayofyear, (position-1) * size(sensorDepth,1) + node + 1])
#          temp = 26.0
            if aDepth >= sensorDepth[node]
              dz = sensorDepth[node-1] - aDepth
              node = size(sensorDepth,1)
              t = simulatedTemperature[aMeteo.dayofyear, (position-1) * size(sensorDepth,1) + node] +
                  (simulatedTemperature[aMeteo.dayofyear, (position-1) * size(sensorDepth,1) + node + 1] -
                   simulatedTemperature[aMeteo.dayofyear, (position-1) * size(sensorDepth,1) + node]) *
                   (aDepth - sensorDepth[node-1]) / (sensorDepth[node] - sensorDepth[node-1])
              temp = 0.5 * (simulatedTemperature[aMeteo.dayofyear, (position-1) * size(sensorDepth,1) + node] + t)
#            temp = 26.0
            end
            if aDvs < 1.0
              fTemperature += dz * interpolate(DvsFactorSoilTemperature1, temp)
            else
              fTemperature += dz * interpolate(DvsFactorSoilTemperature2, temp)
            end
          end
        end
        fTemperature = fTemperature / abs(aDepth)
#        println(aDepth, "   ", temp, "   ", fTemperature)
#        exit(0)
      catch e
        println("???ERROR in Potato.temperatureFactorDvs: ",e)
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
          epp = aMeteo.evapPenman * (1.0 - exp(-1.0 * kDif * kDir * cropYield[aDay-1].potential.lai))
          global cropYield[aDay].dailyPotentialGrowth.potentialPlantEvaporation = epp
          global cropYield[aDay].potential.potentialPlantEvaporation =  cropYield[aDay-1].potential.potentialPlantEvaporation + epp

#          actual
          epp = aMeteo.evapPenman * (1.0 - exp(-1.0 * kDif * kDir * cropYield[aDay-1].actual.lai))
          global cropYield[aDay].dailyActualGrowth.potentialPlantEvaporation = epp
          global cropYield[aDay].actual.potentialPlantEvaporation =  cropYield[aDay-1].actual.potentialPlantEvaporation + epp

#         temperature
          epp = aMeteo.evapPenman * (1.0 - exp(-1.0 * kDif * kDir * cropYield[aDay-1].temperature.lai))
          global cropYield[aDay].dailyTemperatureGrowth.potentialPlantEvaporation = epp
          global cropYield[aDay].temperature.potentialPlantEvaporation =  cropYield[aDay-1].temperature.potentialPlantEvaporation + epp

#         moisture
          epp = aMeteo.evapPenman * (1.0 - exp(-1.0 * kDif * kDir * cropYield[aDay-1].moisture.lai))
          global cropYield[aDay].dailyMoistureGrowth.potentialPlantEvaporation = epp
          global cropYield[aDay].moisture.potentialPlantEvaporation =  cropYield[aDay-1].moisture.potentialPlantEvaporation + epp
        end
      catch e
        println("???ERROR in Potato.computePotentialPlantEvaporation: ", e)
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
        println("???ERROR in Potato.actualPlantEvaporation: ", e)
      end
    finally
    end
  end

  function storeDeltaresData(aDay :: Int64)
    try
      try
        global soilTemperatureAt10cm[aDay] = simulatedTemperature[aDay, (position-1) * size(sensorDepth,1) + 2]
        global soilTemperatureAt20cm[aDay] = simulatedTemperature[aDay, (position-1) * size(sensorDepth,1) + 3]
        global soilTemperatureAt30cm[aDay] = simulatedTemperature[aDay, (position-1) * size(sensorDepth,1) + 4]
        global soilTemperatureAt40cm[aDay] = simulatedTemperature[aDay, (position-1) * size(sensorDepth,1) + 5]
        global pressureHeadAt10cm[aDay] = simulatedHead[aDay, (position-1) * size(sensorDepth,1) + 2]
        global pressureHeadAt20cm[aDay] = simulatedHead[aDay, (position-1) * size(sensorDepth,1) + 3]
        global pressureHeadAt30cm[aDay] = simulatedHead[aDay, (position-1) * size(sensorDepth,1) + 4]
        global pressureHeadAt40cm[aDay] = simulatedHead[aDay, (position-1) * size(sensorDepth,1) + 5]
  #      println(pressureHeadAt40cm[aDay])
      catch e
        println("???ERROR in Potato.storeDeltaresData: ", e)
      end
    finally
    end
  end

  function computeDvsPotential(aMeteo :: Main.Control.Types.Meteo, aDay :: Int64)
    try
      try
        deltaTempSum = interpolate(deltaTempSumAirTemp, aMeteo.aveTemp)
        deltaDvs = 0.0
        if cropYield[aDay].potential.dvs < 1.0
          deltaDvs = deltaTempSum / degDaysEmergenceAnthesis
        else
          deltaDvs = deltaTempSum / degDaysAnthesisMaturity
        end
        cropYield[aDay].dailyPotentialGrowth.tempSum = deltaTempSum
        cropYield[aDay].dailyPotentialGrowth.dvs = deltaDvs
        cropYield[aDay].potential.tempSum += deltaTempSum
        cropYield[aDay].potential.dvs += deltaDvs

#        println(aDay, "   ", aMeteo.aveTemp, "  ", deltaTempSum, "  ", deltaDvs, "  ",cropYield[aDay].potential.tempSum, "  ",cropYield[aDay].potential.dvs)
      catch e
        println("???ERROR in Potato.computeDvsPotential: ",e)
      end
    finally
    end
  end

  function computeDvsMoisture(aMeteo :: Main.Control.Types.Meteo, aDay :: Int64)
    try
      try
        deltaTempSum = interpolate(deltaTempSumAirTemp, aMeteo.aveTemp)
        deltaDvs = 0.0
          if cropYield[aDay].moisture.dvs < 1.0
            deltaDvs = deltaTempSum / degDaysEmergenceAnthesis
          else
            deltaDvs = deltaTempSum / degDaysAnthesisMaturity
          end
          cropYield[aDay].dailyMoistureGrowth.tempSum = deltaTempSum
          cropYield[aDay].dailyMoistureGrowth.dvs = deltaDvs
          cropYield[aDay].moisture.tempSum += deltaTempSum
          cropYield[aDay].moisture.dvs += deltaDvs

  #        println(aDay, "   ", aMeteo.aveTemp, "  ", deltaTempSum, "  ", deltaDvs, "  ",cropYield[aDay].potential.tempSum, "  ",cropYield[aDay].potential.dvs)
        catch e
          println("???ERROR in Potato.computeDvsMoisture: ",e)
        end
      finally
      end
    end

    function computeDvsTemperature(aMeteo :: Main.Control.Types.Meteo, aDay :: Int64, aFactor :: Float64)
      try
        try
          deltaTempSum = interpolate(deltaTempSumAirTemp, aMeteo.aveTemp)
          deltaDvs = 0.0
            if cropYield[aDay].temperature.dvs < 1.0
              deltaDvs = deltaTempSum / degDaysEmergenceAnthesis
            else
              deltaDvs = deltaTempSum / degDaysAnthesisMaturity
            end
            deltaDvs *= aFactor
            cropYield[aDay].dailyTemperatureGrowth.tempSum = deltaTempSum
            cropYield[aDay].dailyTemperatureGrowth.dvs = deltaDvs
            cropYield[aDay].temperature.tempSum += deltaTempSum
            cropYield[aDay].temperature.dvs += deltaDvs

    #        println(aDay, "   ", aMeteo.aveTemp, "  ", deltaTempSum, "  ", deltaDvs, "  ",cropYield[aDay].potential.tempSum, "  ",cropYield[aDay].potential.dvs)
          catch e
            println("???ERROR in Potato.computeDvsTemperature: ",e)
          end
        finally
        end
      end

    function computeDvsActual(aMeteo :: Main.Control.Types.Meteo, aDay :: Int64, aFactor :: Float64)
        try
          try
            deltaTempSum = interpolate(deltaTempSumAirTemp, aMeteo.aveTemp)
            deltaDvs = 0.0
              if cropYield[aDay].actual.dvs < 1.0
                deltaDvs = deltaTempSum / degDaysEmergenceAnthesis
              else
                deltaDvs = deltaTempSum / degDaysAnthesisMaturity
              end
              deltaDvs *= aFactor
              cropYield[aDay].dailyActualGrowth.tempSum = deltaTempSum
              cropYield[aDay].dailyActualGrowth.dvs = deltaDvs
              cropYield[aDay].actual.tempSum += deltaTempSum
              cropYield[aDay].actual.dvs += deltaDvs

      #        println(aDay, "   ", aMeteo.aveTemp, "  ", deltaTempSum, "  ", deltaDvs, "  ",cropYield[aDay].potential.tempSum, "  ",cropYield[aDay].potential.dvs)
            catch e
              println("???ERROR in Potato.computeDvsActual: ",e)
            end
          finally
          end
        end

  function computeRootDepths(aDay :: Int64)
    try
      try
        global cropYield[aDay].potential.rootingDepth = interpolate(RootDepthRootWeight,cropYield[aDay].potential.roots.living)
        global cropYield[aDay].actual.rootingDepth = interpolate(RootDepthRootWeight,cropYield[aDay].actual.roots.living)
        global cropYield[aDay].moisture.rootingDepth = interpolate(RootDepthRootWeight,cropYield[aDay].moisture.roots.living)
        global cropYield[aDay].temperature.rootingDepth = interpolate(RootDepthRootWeight,cropYield[aDay].temperature.roots.living)
      catch e
        println("???ERROR in Potato.computeRootDepths: ",e)
      end
    finally
    end
  end

  function computeGrowth(aMeteo :: Main.Control.Types.Meteo)
    fMoisture = 1.0
    fTemperature = 1.0

    try
      try
        fTemperatureAmax = 1.0
        fTemperatureDvs = 1.0
        day = aMeteo.dayofyear
#        println(day)
        copyPotentialValues(day)
        copyActualValues(day)
        copyMoistureValues(day)
        copyTemperatureValues(day)

        global cropYield[day].dayofyear = day
        global cropYield[day].potentialEp = aMeteo.evapPenman

#        read soil data
        storeDeltaresData(day)

        if !isPlanted
          beforePlanting(aMeteo)
        else
          if !cropIsGrowing
            beforeCropGrowth(aMeteo)
#            println(temperatureSum)
          else
#         compute potential plant evaporation
          computePotentialPlantEvaporation(aMeteo, day)
#         read data from Deltares
          drz = cropYield[day-1].actual.rootingDepth
          fMoisture = moistureFactor(aMeteo, drz)
          actualPlantEvaporation(fMoisture, day)
#          println(fMoisture, "   ", fTemperature)
#         potential growth
          if cropYield[day].potential.dvs < 2.0
            computeDvsPotential(aMeteo, day)
            potentialCropGrowth(aMeteo, day)
          end
          if cropYield[day].moisture.dvs < 2.0
            computeDvsMoisture(aMeteo,day)
            moistureCropGrowth(aMeteo, day, fMoisture)
          end
          if cropYield[day].temperature.dvs < 2.0
            fTemperatureAmax = temperatureFactorAmax(aMeteo, drz, cropYield[day].temperature.dvs)
            fTemperatureDvs = temperatureFactorDvs(aMeteo, drz, cropYield[day].temperature.dvs)
            computeDvsTemperature(aMeteo,day,fTemperatureDvs)
            temperatureCropGrowth(aMeteo,day,fTemperatureAmax)
          end
          if cropYield[day].actual.dvs < 2.0
            fTemperatureAmax = temperatureFactorAmax(aMeteo, drz, cropYield[day].actual.dvs)
            fTemperatureDvs = temperatureFactorDvs(aMeteo, drz, cropYield[day].actual.dvs)
            computeDvsActual(aMeteo,day,fTemperatureDvs)
            actualCropGrowth(aMeteo,day,fMoisture,fTemperatureAmax)
          end
        end
        end
        global cropDate[day] = aMeteo.date
        global cropYieldPotentialLiving[day] = cropYield[day].potential.storage.living
        global cropYieldActualLiving[day] = cropYield[day].actual.storage.living
        global cropYieldMoistureLiving[day] = cropYield[day].moisture.storage.living
        global cropYieldTemperatureLiving[day] = cropYield[day].temperature.storage.living
        global laiPotential[day] = cropYield[day].potential.lai
        global laiActual[day] = cropYield[day].actual.lai
        global laiMoisture[day] = cropYield[day].moisture.lai
        global laiTemperature[day] = cropYield[day].temperature.lai
        global factorMoisture[day] = fMoisture
        global factorTemperature[day] = fTemperatureAmax
        global eppPotential[day] = cropYield[day].potential.potentialPlantEvaporation
        global eppActual[day] = cropYield[day].actual.potentialPlantEvaporation
        global eppMoisture[day] = cropYield[day].moisture.potentialPlantEvaporation
        global eppTemperature[day] = cropYield[day].temperature.potentialPlantEvaporation
        global epaPotential[day] = cropYield[day].potential.actualPlantEvaporation
        global epaActual[day] = cropYield[day].actual.actualPlantEvaporation
        global epaMoisture[day] = cropYield[day].moisture.actualPlantEvaporation
        global epaTemperature[day] = cropYield[day].temperature.actualPlantEvaporation

        computeRootDepths(day)

#        println(day, "   ", cropYield[day].potential.storage.living, "   ", cropYield[day].moisture.storage.living, "   ", cropYield[day].temperature.storage.living, "   ", cropYield[day].actual.storage.living)
      catch e
        println("???ERROR in Potato.computeGrowth: ",e)
    end
    finally
    end
  end

  function plotCrop()
    try
      try
        df = DateFormat("dd-mm-yyyy")
        date1 = Date("01-05-2019",df)
        date2 = Date("15-09-2019",df)
        p = Plots.Plot{Plots.GRBackend}[]
        resize!(p,8)
        p[1] = plot(legend=:topleft, xlabel="Date", ylabel="Grass yield (kg dm/ha)", size=(750,500), xlims = Dates.value.([date1,date2]))
        p[1] = plot!(p[1], cropDate, cropYieldPotentialLiving, label="P", color=:darkgoldenrod2, linestyle=:solid)
        p[1] = plot!(p[1], cropDate, cropYieldActualLiving, label="A", color=:darkred, linestyle=:solid)
        p[1] = plot!(p[1], cropDate, cropYieldMoistureLiving, label="M", color=:blue, linestyle=:solid)
        p[1] = plot!(p[1], cropDate, cropYieldTemperatureLiving, label="T", color=:green2, linestyle=:solid)

        p[2] = plot(legend=:none, xlabel="Datum", ylabel="Factor (-)", size=(750,500), xlims = Dates.value.([date1,date2]))
        p[2] = plot!(p[2], cropDate, factorMoisture, label="Moisture", color=:red, linestyle=:solid)
#        savefig("/home/wesseling/DataDisk/Wesseling/Work/Waterstof/Output/Potatoes/factor_" * string(year) * "_" * string(profile) * "_" * string(position) * ".svg")

        p[3] = plot(legend=:topleft, xlabel="Date", ylabel="LAI (m2/m2)", size=(750,500), xlims = Dates.value.([date1,date2]))
        p[3] = plot!(p[3], cropDate, laiPotential, label="P", color=:darkgoldenrod2, linestyle=:solid)
        p[3] = plot!(p[3], cropDate, laiActual, label="A", color=:darkred, linestyle=:solid)
        p[3] = plot!(p[3], cropDate, laiMoisture, label="M", color=:blue, linestyle=:solid)
        p[3] = plot!(p[3], cropDate, laiTemperature, label="T", color=:green2, linestyle=:solid)

        p[4] = plot(legend=:none, xlabel="Datum", ylabel="Factor (-)", size=(750,500), xlims = Dates.value.([date1,date2]))
        p[4] = plot!(p[4], cropDate, factorTemperature, label="Temperature", color=:red, linestyle=:solid)
#        savefig("/home/wesseling/DataDisk/Wesseling/Work/Waterstof/Output/Potatoes/factor_" * string(year) * "_" * string(profile) * "_" * string(position) * ".svg")

        p[5] = plot(legend=:topleft, xlabel="Date", ylabel="Epp (mm)", size=(750,500), xlims = Dates.value.([date1,date2]))
        p[5] = plot!(p[5], cropDate, eppPotential, label="P", color=:darkgoldenrod2, linestyle=:solid)
        p[5] = plot!(p[5], cropDate, eppActual, label="A", color=:darkred, linestyle=:solid)
        p[5] = plot!(p[5], cropDate, eppMoisture, label="M", color=:blue, linestyle=:solid)
        p[5] = plot!(p[5], cropDate, eppTemperature, label="T", color=:green2, linestyle=:solid)

        p[6] = plot(legend=:topleft, xlabel="Date", ylabel="Epa (mm)", size=(750,500), xlims = Dates.value.([date1,date2]))
        p[6] = plot!(p[6], cropDate, epaPotential, label="P", color=:darkgoldenrod2, linestyle=:solid)
        p[6] = plot!(p[6], cropDate, epaActual, label="A", color=:darkred, linestyle=:solid)
        p[6] = plot!(p[6], cropDate, epaMoisture, label="M", color=:blue, linestyle=:solid)
        p[6] = plot!(p[6], cropDate, epaTemperature, label="T", color=:green2, linestyle=:solid)

        p[7] = plot(legend=:topleft, xlabel="Date", ylabel="Temperature (C)", size=(750,500), xlims = Dates.value.([date1,date2]))
        p[7] = plot!(p[7], cropDate, soilTemperatureAt10cm, label = "10 cm", color=:darkred, linestyle=:solid)
        p[7] = plot!(p[7], cropDate, soilTemperatureAt20cm, label = "20 cm", color=:blue, linestyle=:solid)
        p[7] = plot!(p[7], cropDate, soilTemperatureAt30cm, label = "30 cm", color=:aqua, linestyle=:solid)
        p[7] = plot!(p[7], cropDate, soilTemperatureAt40cm, label = "40 cm", color=:green2, linestyle=:solid)

        x = Array{Date}(undef,2)
        y = Array{Float64}(undef,2)
        x[1] = cropDate[1]
        x[2] = cropDate[size(cropDate,1)]
        y[1] = -25.0
        y[2] = -25.0
        p[8] = plot(legend=:topleft, xlabel="Date", ylabel="Pressure head (cm)", size=(750,500), xlims = Dates.value.([date1,date2]), yaxis=:log)
        p[8] = plot!(p[8], x, abs.(y), label = "limiet 1", color=:blue, linestyle=:dot)
        y[1] = -300.0
        y[2] = -300.0
        p[8] = plot!(p[8], x, abs.(y), label = "limiet 2", color=:red, linestyle=:dot)
        p[8] = plot!(p[8], cropDate, abs.(pressureHeadAt10cm), label = "10 cm", color=:darkred, linestyle=:solid)
        p[8] = plot!(p[8], cropDate, abs.(pressureHeadAt20cm), label = "20 cm", color=:blue, linestyle=:solid)
        p[8] = plot!(p[8], cropDate, abs.(pressureHeadAt30cm), label = "30 cm", color=:aqua, linestyle=:solid)
        p[8] = plot!(p[8], cropDate, abs.(pressureHeadAt40cm), label = "40 cm", color=:green2, linestyle=:solid)
        pAll = plot(p..., layout=(4,2), size=(1500,2000))

        savefig("/home/wesseling/DataDisk/Wesseling/Work/Waterstof/Output/Potatoes/cropyield_" * string(year) * "_" * string(profile) * "_" * string(position) * ".svg")

        display(pAll)

      catch e
        println("???ERROR in Potato.plotCrop: ", e)
      end
    finally
    end
  end

  function storeOutput(aYear :: Int64)
    fileName = "/home/wesseling/DataDisk/Wesseling/Work/Waterstof/Output/Potatoes/results_" * string(year) * "_" * string(profile) * "_" * string(position) * ".txt"
    df = DateFormat("dd-u-yyyy HH:MM:SS.sss")
    df1 = DateFormat("dd-u-yyyy")

    try
      try
        baseDate = Dates.Date(aYear,1,1)
        emergenceDate = Dates.format(baseDate + Dates.Day(dayOfEmergence-1), df1)
        global actualDateEmergence = emergenceDate

        dayMaturePotential = 1
        yieldPotential = 0.0
        for i in 1:365
          if cropYield[i].potential.dvs > 2.0
            dayMaturePotential = i
            yieldPotential = cropYield[i].potential.storage.living
            global potentialYield = yieldPotential
            break
          end
        end
        dateMaturePotential = Dates.format(baseDate + Dates.Day(dayMaturePotential-1),df1)
        dayMatureActual = 1
        yieldActual = 0.0
        for i in 1:365
          if cropYield[i].actual.dvs > 2.0
            dayMatureActual = i
            yieldActual = cropYield[i].actual.storage.living
            global actualYield = yieldActual
            break
          end
        end
        dateMatureActual = Dates.format(baseDate + Dates.Day(dayMatureActual-1),df1)
        global actualDateMature = dateMatureActual
        dayMatureMoisture = 1
        yieldMoisture = 0.0
        for i in 1:365
          if cropYield[i].moisture.dvs > 2.0
            dayMatureMoisture = i
            yieldMoisture = cropYield[i].moisture.storage.living
            global moistureYield = yieldMoisture
            break
          end
        end
        dateMatureMoisture = Dates.format(baseDate + Dates.Day(dayMatureMoisture-1),df1)
        dayMatureTemperature = 1
        yieldTemperature = 0.0
        for i in 1:365
          if cropYield[i].temperature.dvs > 2.0
            dayMatureTemperature = i
            yieldTemperature = cropYield[i].temperature.storage.living
            global temperatureYield = yieldTemperature
            break
          end
        end
        dateMatureTemperature = Dates.format(baseDate + Dates.Day(dayMatureTemperature-1),df1)

        myString = "Results of PotatoGrowth. \nDate : " * Dates.format(Dates.now(),df) * "\n\n"
        myString *= "Item                            Potential              Actual            Moisture         Temperature\n"

        myString *= "Epp (mm)             "
        myString *= lpad(string(floor(Int64,cropYield[dayMaturePotential].potential.potentialPlantEvaporation)),20," ")
        myString *= lpad(string(floor(Int64,cropYield[dayMatureActual].actual.potentialPlantEvaporation)),20," ")
        myString *= lpad(string(floor(Int64,cropYield[dayMatureMoisture].moisture.potentialPlantEvaporation)),20," ")
        myString *= lpad(string(floor(Int64,cropYield[dayMatureTemperature].temperature.potentialPlantEvaporation)),20," ")
        myString *= "\n"

        myString *= "Epa (mm)             "
        myString *= lpad(string(floor(Int64,cropYield[dayMaturePotential].potential.actualPlantEvaporation)),20," ")
        myString *= lpad(string(floor(Int64,cropYield[dayMatureActual].actual.actualPlantEvaporation)),20," ")
        myString *= lpad(string(floor(Int64,cropYield[dayMatureMoisture].moisture.actualPlantEvaporation)),20," ")
        myString *= lpad(string(floor(Int64,cropYield[dayMatureTemperature].temperature.actualPlantEvaporation)),20," ")
        myString *= "\n"
        global actualTranspiration = cropYield[dayMatureActual].actual.actualPlantEvaporation

        myString *= "Emergence            "
        myString *= lpad(emergenceDate * " (" * string(dayOfEmergence) * ")",20," ")
        myString *= lpad(emergenceDate * " (" * string(dayOfEmergence) * ")",20," ")
        myString *= lpad(emergenceDate * " (" * string(dayOfEmergence) * ")",20," ")
        myString *= lpad(emergenceDate * " (" * string(dayOfEmergence) * ")",20," ")
        myString *= "\n"

        myString *= "Maturity             "
        myString *= lpad(dateMaturePotential * " (" * string(dayMaturePotential) * ")",20," ")
        myString *= lpad(dateMatureActual * " (" * string(dayMatureActual) * ")",20," ")
        myString *= lpad(dateMatureMoisture * " (" * string(dayMatureMoisture) * ")",20," ")
        myString *= lpad(dateMatureTemperature * " (" * string(dayMatureTemperature) * ")",20," ")
        myString *= "\n"

        myString *= "Harvest (kg d.m./ha) "
        myString *= lpad(string(floor(Int64,yieldPotential)),20," ")
        myString *= lpad(string(floor(Int64,yieldActual)),20," ")
        myString *= lpad(string(floor(Int64,yieldMoisture)),20," ")
        myString *= lpad(string(floor(Int64,yieldTemperature)),20," ")
        myString *= "\n"

        outFile = open(fileName, "w")
        println(outFile, myString)
        close(outFile)

#        pot = cropYield[289].potential.mowed + cropYield[289].potential.total.dead + cropYield[289].potential.total.living
#        tmp = cropYield[289].temperature.mowed + cropYield[289].temperature.total.dead + cropYield[289].temperature.total.living
#        dif = tmp - pot
#        proc = 100 * dif / pot
#        println(pot, "   ", tmp, "   ", dif, "   ", proc)
      catch e
        println("????ERROR in Potato.storeOutput: ",e)
        exit(0)
      end
    finally
    end
  end

end
