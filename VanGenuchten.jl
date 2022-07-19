module VanGenuchten

  params = Array{Main.Control.Types.VGParams}

  function setNumberOfLayers(aNumber :: Int64)
    resize!(params, aNumber)
    for i in 1:aNumber
      params[i] = Main.Control.Types.VGParams(0.0,0.0,0.0,0.0,0.0,0.0)
    end
  end

  public void setParameters(aLayer :: Int64, aThetaR :: Float64, aThetaS :: Float64,
          aKsat :: Float64, aAlpha :: Float64, al :: Float64, an :: Float64)
    status = 0
    try
      try
        params[aLayer].thetaR = aThetaR
        params[aLayer].thetaS = aThetaS
        params[aLayer].kSat = aKSat
        params[aLayer].alpha = aAlpha
        params[aLayer].l = al
        params[aLayer].n = an
        params[aLayer].m = 1.0 - (1.0 / an)
      catch e
        status = 1
        println("?????ERROR in VanGenuchten.setParameters: ", e)
      end
    finally
    end
    return status
  end


  function moistureContent(aLayer :: Int64, ah :: Float64)
    theta = 0.0;
    try
      try
        if ah > -1.0e-4
          theta = params[aLayer].thetaS
        else
          head = 100.0 * ah
          # first compute |alpha * h| ** n
          help = abs(params[aLayer].alpha * head)^params[aLayer].n

          # add 1 and raise to the power m
          help = (1.0 + help) ^ params[aLayer].m

          # now compute theta
          theta = params[aLayer].thetaR + (params[aLayer].thetaS - params[aLayer].thetaR) / help
        end
      catch e
        println("?????ERROR in VanGenuchten.moistureContent: ",e)
      end
    finally
    end
    return theta
  end

  function pressureHead(aLayer :: Int64, aTheta :: Float64)
  {
    # calculation of h from theta
    h = 0.0
    try
      try
        help = 0.0
        if ((aTheta < params[aLayer].thetaR) || (aTheta > params[aLayer].thetaS))
          help = 1.0e3
        else
          # first calculate the inverse of the sorptivity }
          help = (params[aLayer].thetaS - params[aLayer].thetaR) / (aTheta - params[aLayer].thetaR);

          # raise to the power 1/m
          if (abs(params[aLayer].n) < 1.0e-4) || (abs(params[aLayer].m) < 1.0e-4)
            help = 1.0e28
          else
          if log10(help) / params[aLayer].m > 28.0
            help = 1.0e28
          else
            help = help ^ (1.0 / params[aLayer].m)
          if abs(help - 1.0) < 1.0e-3
            help = 1.0e28
          else
            # subtract one and raise to the power 1/n }
            if log10(help-1.0) / params[aLayer].n > 28.0
              help = 1.0e28
            else
              help = (help - 1.0)^(1.0 / params[aLayer].n)
              # divide by alpha
              help = -1.0 * Math.abs(help/params[aLayer].alpha);
            }
          }
        }
      }
    }
    help = 0.01 * help
    return help
  }

  public double conductivity(aLayer :: Int64, double ah)
  {
    head = 100.0 * ah
    term1=0.0
    term2=0.0
    alphaN=0.0
    try
      try
        if head > -0.0001
          term1 = params[aLayer].kSat
        else
          # term1 = (1 + |alfa * h| ^ n ) ^ m
          alphaH = abs(params[aLayer].alpha * head)
          logTerm = log10(alphaH)
          if params[aLayer].n * logTerm > 28.0
            term1 = 1.0e28
          else
            alphaN = alphaH^params[aLayer].n
            help = 1.0 + alphaN
            if params[aLayer].n * logTerm > 28.0
              term1 = 1.0e28
            else
              term1 = help^params[aLayer].m
            end
          end

          # term2 = |alfa * h| ^ (n-1)
          help  = params[aLayer].n - 1.0
          if help * logTerm > 28.0
            term2 = 1.0e28
          else
            term2 = alphaH^help
          end

          # the difference
          term1 = term1 - term2
          term2 = term1 * term1
          # now term2 is the nominator

          # the denominator
          term3 = 1.0 + alphaN
          if params[aLayer].m * (params[aLayer].l+2.0) * log10(term3) > 28.0
            term1 = 1.0e28;
          else
            term3 = term3 * (params[aLayer].m*(params[aLayer].l+2.0))
            # the conductivity in cm/d
              term1 = kSat * term2 / term3;
          end
        end
        # convert to m/s
        term1 = 0.01 * term1 / 86400.0;
      catch e
        println("?????ERROR in VanGenuchten.conductivity: ",e)
      end
    finally
    end
    return term1
  end

  function moistureCapacity(aLayer :: Int64, ah :: Float64)
  {
    result = 0.0
    try
      try
        if ah > -1.0e-3
          result = 0.0
        else
          # convert to cm
          head = 100.0 * ah
          # use analytical evaluation of capacity
          alphaH = abs(params[aLayer].alpha * head)

          # compute |alpha * h| to the power n-1
          term1 = alphaH ^  (params[aLayer].n-1.0)

          # compute |alpha*h| to the power n
          term2 = term1 * alphaH;

          # add one and raise to the power m+1
          term2 = (1.0 + term2) ^ (params[aLayer].m + 1.0)

          # divide theta-s minus theta-r by term2
          term2 = (params[aLayer].thetaS - params[aLayer].thetaR) / term2;

          # calculate the differential moisture capacity
          result = 100.0 * (params[aLayer].n * params[aLayer].m * params[aLayer].alpha * term2 * term1);
        end

      catch e
        result = 1.0e28;
        println("?????ERROR in VanGenuchten.moistureCapacity: ",e)
      end
    fially
    end
    return result;
  end


}

end
