module Meteo


# calculates the latent heat of vaporization (MJ/kg) at temperature
#   TemperatureInC (C). Eq. (1.1) }
  function latentHeatOfVaporization(aTemp :: Float64)
    labda = -1.0
    try
      try
        labda = 2.501 - 0.002361 * aTemp
      catch e
        println("???ERROR in latentHeatOfVaporization: ",e)
      end
    finally
    end
    return labda
  end

# calculates the slope of the vapor pressure curve (kPa/C) at
#    temperature TemperatureInC (C). Eq. 1.3 ) }

  function slopeOfVapourPressureCurve(aTemp :: Float64)
    delta = -1.0
    try
      try
        delta = (2504.0 * exp((17.27 * aTemp) / (aTemp + 237.3))) / ((aTemp + 237.3) * (aTemp + 237.3))
      catch e
        println("???ERROR in slopeOfVapourPressureCurve: ",e)
      end
    finally
    end
    return delta
  end


  function saturationVapourPressure(aTemp :: Float64)
    es = -1.0
    try
      try
        es = 0.611 * exp((17.27 * aTemp) / (aTemp + 237.3))
      catch e
        println("???ERROR in saturationVapourPressure: ",e)
      end
    finally
    end
    return es
  end


  function saturationVapourPressure24h(aTmin :: Float64, aTmax :: Float64)
    es = -1.0
    try
      try
        es = 0.5 * (saturationVapourPressure(aTmin) + saturationVapourPressure(aTmax))
      catch e
        println("???ERROR in saturationVapourPressure24h: ",e)
      end
    finally
    end
    return es
  end

  function actualVapourPressure(aRelHum :: Float64, aTmin :: Float64, aTmax :: Float64)
    ea = -1.0
    try
      try
        ea = aRelHum / ((50.0 / saturationVapourPressure(aTmin)) + (50.0 / saturationVapourPressure(aTmax)))
      catch e
        println("???ERROR in actualVapourPressure: ",e)
      end
    finally
    end
    return ea
  end

  function vapourPressureDeficit(aRelHum :: Float64, aTmin :: Float64, aTmax :: Float64)
    vpd = -1.0
    try
      try
        vpd = saturationVapourPressure24h(aTmin, aTmax) - actualVapourPressure(aRelHum, aTmin, aTmax)
      catch e
        println("???ERROR in vapourPressureDeficit: ",e)
      end
    finally
    end
    return vpd
  end

# calulates the value of the psychrometric constant (kPa/C) from
#    the atmospheric pressure (kPa) and latent heat of vaporization (MJ/kg)
  function psychrometricConstant(aAtmosphericPressureInKPa :: Float64, aLatentHeatOfVaporization :: Float64)
    gamma = -1.0
    try
      try
        gamma = 0.00163 * aAtmosphericPressureInKPa / aLatentHeatOfVaporization;
      catch e
        println("???ERROR in psychrometricConstant: ",e)
      end
    finally
    end
    return gamma
  end

  function soilHeatFlux(aTave :: Float64, aTprevious :: Float64)
    flux = -1.0
    try
      try
        flux = 0.38 * (aTave - aTprevious)
      catch e
        println("???ERROR in soilHeatFlux: ",e)
      end
    finally
    end
    return flux
  end

  # converts the solar radiation into net shortwave radiation using the albedo

  function netRadiationForGrass(aRs :: Float64)
    albedo = 0.23;
    rn = -1.0
    try
      rn = (1.0 - albedo) * aRs;
    catch
      println("???ERROR in netRadiationForGrass: ",e)
    finally
    end
    return rn
  end

  function computePressure()
    pressure = -1.0
    referencePressureInKPa = 101.3
    referenceElevationInMeters = 0.0
    referenceTemperatureInC = 20.0
    altitude = -4.3
    try
      try
        alfa = 0.0065 # {K/m}
        R = 287.0 #  { J /kg / K }
        g = 9.81 # { m/s2 }
        help1 = ReferenceTemperatureInC + 273.15
        help1 = (help1 - alfa * (altitude - ReferenceElevationInMeters)) / help1
        help2 = g / (alfa * R)
        pressure = ReferencePressureInKPa * power(help1, help2)
      catch e
        println("???ERROR in computePressure: ", e)
      end
    finally
    end
    return pressure
  end


  function computeEvapPenman(aTave :: Float64, aTprevious :: Float64,
                             aTmin :: Float64, aTmax :: Float64, aRs :: Float64,
                             aRelHum :: Float64, aWind :: Float64, aPressure :: Float64)
    evap = -1.0
    try
      try
        pressure = aPressure
        labda = latentHeatOfVaporization(aTave)
        netRadiation = netRadiationForGrass(aRs)
        rSoilHeat = soilHeatFlux(aTave, aTprevious)
        delta = slopeOfVapourPressureCurve(aTave)
        gamma = psychrometricConstant(pressure, labda)
        vpd = vapourPressureDeficit(aRelHum, aTmin, aTmax)
        nomin1 = 0.408 * delta * (netRadiation - rSoilHeat)
        nomin2 = gamma * (900.0 / (aTave + 273)) * aWind * vpd
        denomin = delta + gamma * (1.0 + 0.34 * aWind)
        evap = (nomin1 + nomin2) / denomin
        evap = 0.00352 * evap / labda
      catch e
        println("???ERROR in computeEvapPenman: ",e)
      end
    finally
    end
    return evap
  end


end
