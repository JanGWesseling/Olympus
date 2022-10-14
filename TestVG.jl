using MySQL
using DataFrames

mutable struct MVGParam
   id :: Int64
   thetaR :: Float64
   thetaS :: Float64
   kSat :: Float64
   alpha :: Float64
   l :: Float64
   n :: Float64
   m :: Float64
 end


function moistureContent(aData :: MVGParam, ah :: Float64)
  theta = 0.0;
  try
    try
      if ah > -1.0e-4
        theta = aData.thetaS
      else
        head = ah
        # first compute |alpha * h| ** n
        help = abs(aData.alpha * head)^aData.n

        # add 1 and raise to the power m
        help = (1.0 + help) ^ aData.m

        # now compute theta
        theta = aData.thetaR + (aData.thetaS - aData.thetaR) / help
      end
    catch e
      println("?????ERROR in VanGenuchten.moistureContent: ",e)
    end
  finally
  end
  return theta
end

function pressureHead(aData :: MVGParam, aTheta :: Float64)
  # calculation of h from theta
  h = 0.0
  try
    try
      help = 0.0
      if ((aTheta < aData.thetaR) || (aTheta > aData.thetaS))
        help = 1.0e3
      else
        # first calculate the inverse of the sorptivity }
        help = (aData.thetaS - aData.thetaR) / (aTheta - aData.thetaR);

        # raise to the power 1/m
        if (abs(aData.n) < 1.0e-4) || (abs(aData.m) < 1.0e-4)
          help = 1.0e28
        else
          if log10(help) / aData.m > 28.0
            help = 1.0e28
          else
            help = help ^ (1.0 / aData.m)
            if abs(help - 1.0) < 1.0e-3
              help = 1.0e28
            else
              # subtract one and raise to the power 1/n }
              if log10(help-1.0) / aData.n > 28.0
                help = 1.0e28
              else
                help = (help - 1.0)^(1.0 / aData.n)
                # divide by alpha
                help = -1.0 * Math.abs(help/aData.alpha);
              end
            end
          end
        end
      end
    catch ex
      println("ERROR in VanGenuchten.pressureHead: ",ex)
    end
  finally
  end
  return help
end

function readStaringParams()
  staring = Array{MVGParam}(undef,0)
  try
    try
      myConnection = DBInterface.connect(MySQL.Connection,"127.0.0.1", "bofek","bofek", db="bofek")
      sql = "SELECT * FROM staringparams ORDER BY staringid;"
      result = DBInterface.execute(myConnection, sql) |> DataFrame
      n = size(result,1)
      resize!(staring, n)
      for i in 1:n
        m = 1.0 - (1.0 / result[i,7])
        myStaring = MVGParam(result[i,1], result[i,2], result[i,3], result[i,4], result[i,5], result[i,6], result[i,7], m)
        staring[i] = myStaring
      end
      DBInterface.close!(myConnection)
    catch ex
      println("???ERROR in readStaringParams: ",ex)
    end
  finally
  end
  return staring
end

vGParams = readStaringParams()
vGParams[30].kSat = 10.0
vGParams[30].thetaS = 0.56
vGParams[30].alpha = 0.95
vGParams[30].l = -4.171
vGParams[30].n = 1.159
vGParams[30].m = 1.0 - (1.0 / vGParams[30].n)


println()
println("h= ")
x = readline()
h = parse(Float64,x)
theta = moistureContent(vGParams[30], h)
println(h, "    ", theta)
