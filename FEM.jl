module FEM
  using LinearAlgebra
  using Plots
  using Dates
  using BandedMatrices
  using Printf

  xCoord = Array{Float64}
  yCoord = Array{Float64}
  zCoord = Array{Float64}
  nXY = 0
  nXYe = 0
  nCubicElements = 0
  nElements = 0
  nNodes = 0
  matrixA = BandedMatrix
  bandWidth = 0
  vectorB = Array{Float64}
  state = Array{Main.Control.Types.State}(undef,1)
  node = Array{Main.Control.Types.Node}(undef,1)
  cubicElement = Array{Main.Control.Types.CubicElement}(undef, 1)
  element = Array{Main.Control.Types.Element}(undef,1)
  labda = Array{Float64}(undef,3,3)
  heatCapacity = 2.0e6
  timing = Main.Control.Types.Timing(Dates.now(), Dates.now(), 100.0, 100.0, Dates.now(), false)


  function setCoordinates(aX::Array{Float64}, aY::Array{Float64}, aZ::Array{Float64})
    global xCoord = aX
    global yCoord = aY
    global zCoord = aZ
  end

  function createNodes()
    status = 0
    n = 0
    global nXY = size(xCoord,1) * size(yCoord,1)
    global nXYe = (size(xCoord,1) - 1) * (size(yCoord,1) - 1)
    global bandWidth = nXY + nXYe + size(yCoord,1) + 1
    arraySize = size(xCoord,1) * size(yCoord,1) * size(zCoord,1) + (size(zCoord,1)-1) * nXYe
#    println(arraySize)
    resize!(node, arraySize)
    try
      try
        for k in 1:size(zCoord,1)
          for j = 1:size(xCoord,1)
            for i in 1:size(yCoord,1)
              n += 1
              xArray = Array{Float64}(undef,3)
              xArray[1] = xCoord[j]
              xArray[2] = yCoord[i]
              xArray[3] = zCoord[k]
              global node[n] = Main.Control.Types.Node(xArray)
            end
          end
          if k < size(zCoord,1)
            n += nXYe
          end
        end
        global nNodes = size(node,1)
#        println(nNodes)
      catch e
        println("???Error in createNodes: " * e)
        status = 1
      end
    finally
      if n != arraySize
        status = 2
        println("???Error in createNodes")
      end
    end
    return status
  end

  function addCenterNodes()
    status = 0
    try
      try
        for k in 1:size(zCoord,1)-1
          n = k * nXY + (k-1) * nXYe
          for i in 1:size(xCoord,1)-1
            for j in 1:size(yCoord,1)-1
              n += 1
              xArray = Array{Float64}(undef,3)
              xArray[1] = (4.0 * xCoord[i] + 4.0 * xCoord[i+1]) / 8.0
              xArray[2] = (4.0 * yCoord[j] + 4.0 * yCoord[j+1]) / 8.0
              xArray[3] = (4.0 * zCoord[k] + 4.0 * zCoord[k+1]) / 8.0
              global node[n] = Main.Control.Types.Node(xArray)
            end
          end
        end
#        println(node[122])
#        println(node[2210])
      catch e
        println("????Error in FEM.addCenterNodes: ",e)
        status = 1
      end
    finally
    end
    return status
  end

  function createCubicElements()
    status = 0
    nX = size(xCoord,1)
    nY = size(yCoord,1)
    nZ = size(zCoord,1)
    global nCubicElements = (nX - 1) * (nY -1) * (nZ - 1)
#    println(nCubicElements)
    resize!(cubicElement, nCubicElements)
    try
      try
        n = 0
        xyBase = -1 * (nXY + nXYe)
        for k in 1:nZ-1
          xBase = -1 * nY
          xyBase += nXY + nXYe
          for i in 1:nX-1
            xBase += nY
            for j in 1:nY-1
              n += 1
  #            println(n)
              c = Array{Int64}(undef,9)
              c[5] = xyBase + xBase + j
              c[6] = c[5] + nY
              c[7] = c[6] + 1
              c[8] = c[5] + 1
              for l in 1:4
                c[l] = c[l+4] + nXY + nXYe
              end
              c[9] = xyBase + nXY + (i-1) * (nY-1) + j
              global cubicElement[n] = Main.Control.Types.CubicElement(c)
            end
          end
        end
#        println(cubicElement[1])
#        println(cubicElement[100])
#        println(cubicElement[1000])
      catch e
        println("???Error in createCubicElements :")
        println(e)
        status = -1
      end
    finally
#      println(cubicElement)
    end
    return status
  end

  function plotCubicElements()
    p = plot(legend=false)

    x = Array{Float64}(undef,5)
    y = Array{Float64}(undef,5)
    z = Array{Float64}(undef,5)

    for i in 1:nCubicElements
      # top area
      if node[cubicElement[i].corner[5]].x[3] == zCoord[1]
        x[1] = node[cubicElement[i].corner[5]].x[1]
        x[2] = node[cubicElement[i].corner[6]].x[1]
        x[3] = node[cubicElement[i].corner[7]].x[1]
        x[4] = node[cubicElement[i].corner[8]].x[1]
        x[5] = x[1]

        y[1] = node[cubicElement[i].corner[5]].x[2]
        y[2] = node[cubicElement[i].corner[6]].x[2]
        y[3] = node[cubicElement[i].corner[7]].x[2]
        y[4] = node[cubicElement[i].corner[8]].x[2]
        y[5] = y[1]

        z[1] = node[cubicElement[i].corner[5]].x[3]
        z[2] = node[cubicElement[i].corner[6]].x[3]
        z[3] = node[cubicElement[i].corner[7]].x[3]
        z[4] = node[cubicElement[i].corner[8]].x[3]
        z[5] = z[1]

        p = plot!(p, x,y,z,color="black")
      end

      # front area
      if node[cubicElement[i].corner[5]].x[2] == zCoord[1]
        x[1] = node[cubicElement[i].corner[1]].x[1]
        x[2] = node[cubicElement[i].corner[2]].x[1]
        x[3] = node[cubicElement[i].corner[6]].x[1]
        x[4] = node[cubicElement[i].corner[5]].x[1]
        x[5] = x[1]

        y[1] = node[cubicElement[i].corner[1]].x[2]
        y[2] = node[cubicElement[i].corner[2]].x[2]
        y[3] = node[cubicElement[i].corner[6]].x[2]
        y[4] = node[cubicElement[i].corner[5]].x[2]
        y[5] = y[1]

        z[1] = node[cubicElement[i].corner[1]].x[3]
        z[2] = node[cubicElement[i].corner[2]].x[3]
        z[3] = node[cubicElement[i].corner[6]].x[3]
        z[4] = node[cubicElement[i].corner[5]].x[3]
        z[5] = z[1]

        p = plot!(p, x,y,z,color="black")
      end

      # right area
      if node[cubicElement[i].corner[2]].x[1] == xCoord[size(xCoord,1)]
        x[1] = node[cubicElement[i].corner[2]].x[1]
        x[2] = node[cubicElement[i].corner[3]].x[1]
        x[3] = node[cubicElement[i].corner[7]].x[1]
        x[4] = node[cubicElement[i].corner[6]].x[1]
        x[5] = x[1]

        y[1] = node[cubicElement[i].corner[2]].x[2]
        y[2] = node[cubicElement[i].corner[3]].x[2]
        y[3] = node[cubicElement[i].corner[7]].x[2]
        y[4] = node[cubicElement[i].corner[6]].x[2]
        y[5] = y[1]

        z[1] = node[cubicElement[i].corner[2]].x[3]
        z[2] = node[cubicElement[i].corner[3]].x[3]
        z[3] = node[cubicElement[i].corner[7]].x[3]
        z[4] = node[cubicElement[i].corner[6]].x[3]
        z[5] = z[1]

        p = plot!(p, x,y,z,color="black")
      end
    end
#=
    nodeText = Array{String}(undef, 1)
    xNode = Array{Float64}(undef,1)
    yNode = Array{Float64}(undef,1)
    zNode = Array{Float64}(undef,1)
    n = 0

    for i in 1:size(node, 1)
      if node[i].x == xCoord[size(xCoord,1)] || node[i].y == yCoord[1] || node[i].z == zCoord[1]
        n += 1
        resize!(nodeText, n)
        resize!(xNode, n)
        resize!(yNode, n)
        resize!(zNode, n)

        nodeText[n] = string(i)
        xNode[n] = node[i].x
        yNode[n] = node[i].y
        zNode[n] = node[i].z
      end
    end
    p = annotate!(p, xNode, yNode, zNode, nodeText, color = "red")
    println(xNode)
    println(yNode)
    println(zNode)
    println(nodeText)
=#
    savefig("/home/wesseling/DataDisk/Wesseling/WesW/3d/Output/cubes.svg")
  end

  function plotElements()
    x = Array{Float64}(undef,1)
    y = Array{Float64}(undef,1)
    z = Array{Float64}(undef,1)
    myColor = [:red, :blue, :green, :orange, :lime, :grey, :red, :blue, :green, :orange, :lime, :grey]
    pAll = plot(legend=false)
    p = Array{Any}(undef,12)
    for m in 1:12
      resize!(x,4)
      resize!(y,4)
      resize!(z,4)
      for j in 1:3
        x[j] = node[element[m].corner[j]].x[1]
        y[j] = node[element[m].corner[j]].x[2]
        z[j] = node[element[m].corner[j]].x[3]
      end
      x[4] = node[element[m].corner[1]].x[1]
      y[4] = node[element[m].corner[1]].x[2]
      z[4] = node[element[m].corner[1]].x[3]

      p[m] = plot(x,y,z, color=myColor[m])
      pAll = plot!(pAll, x,y,z, color=myColor[m])

      resize!(x,2)
      resize!(y,2)
      resize!(z,2)

      x[1] = node[element[m].corner[4]].x[1]
      y[1] = node[element[m].corner[4]].x[2]
      z[1] = node[element[m].corner[4]].x[3]

      for j in 1:3
        x[2] = node[element[m].corner[j]].x[1]
        y[2] = node[element[m].corner[j]].x[2]
        z[2] = node[element[m].corner[j]].x[3]
        p[m] = plot!(p[m], x,y,z, color=myColor[m])
        pAll = plot!(pAll, x,y,z, color=myColor[m])
      end
    end
    pTot = plot(p[1],p[2],p[3],p[4],p[5],p[6],p[7],p[8],p[9],p[10],p[11],p[12],pAll,legend=false,size=(2400,1600), xaxis_range=[0.0,0.1],yaxis_range=[0.0,0.1],zaxis_range=[-0.1,0.0])
    display(pTot)

    savefig("/home/wesseling/DataDisk/Wesseling/WesW/3d/Output/plots.svg")
  end

  function volumeOfElement()
    status = 0
    mat = Array{Float64}(undef,4,4)
    try
      try
        for m in 1:nElements
          for i in 1:size(element[m].corner,1)
            mat[i,1] = 1.0
            mat[i,2] = node[element[m].corner[i]].x[1]
            mat[i,3] = node[element[m].corner[i]].x[2]
            mat[i,4] = node[element[m].corner[i]].x[3]
          end
          global element[m].volume = det(mat)/6.0
          if element[m].volume <= 0.0
            println("????Volume <= 0 of element ",m,":   ", element[m].volume)
            status = 1
          end
        end
      catch e
        println("???ERROR in volumeOfElement: ",e)
        status = -1
      end
    finally
#      println(vol)
    end
    return status
  end


  function splitCubes()
    status = 0
    global nElements = 0
    try
      try
        global nElements = 12 * nCubicElements
        resize!(element, nElements)
        e = 0
        for m in 1:nCubicElements
#         front
          alpha = Array{Float64}(undef,4,3)
          newE = Array{Int64}(undef,4)
          newE[1] = cubicElement[m].corner[1]
          newE[2] = cubicElement[m].corner[2]
          newE[3] = cubicElement[m].corner[9]
          newE[4] = cubicElement[m].corner[5]
          e += 1
          global element[e] = Main.Control.Types.Element(newE, 0.0, alpha)
#          println(e,element[e])

          alpha = Array{Float64}(undef,4,3)
          newE = Array{Int64}(undef,4)
          newE[1] = cubicElement[m].corner[2]
          newE[2] = cubicElement[m].corner[9]
          newE[3] = cubicElement[m].corner[5]
          newE[4] = cubicElement[m].corner[6]
          e += 1
          global element[e] = Main.Control.Types.Element(newE, 0.0, alpha)
#          println(e,element[e])

#         right
          alpha = Array{Float64}(undef,4,3)
          newE = Array{Int64}(undef,4)
          newE[1] = cubicElement[m].corner[2]
          newE[2] = cubicElement[m].corner[3]
          newE[3] = cubicElement[m].corner[9]
          newE[4] = cubicElement[m].corner[6]
          e += 1
          global element[e] = Main.Control.Types.Element(newE, 0.0, alpha)
#          println(element[e])

          alpha = Array{Float64}(undef,4,3)
          newE = Array{Int64}(undef,4)
          newE[1] = cubicElement[m].corner[3]
          newE[2] = cubicElement[m].corner[9]
          newE[3] = cubicElement[m].corner[6]
          newE[4] = cubicElement[m].corner[7]
          e += 1
          global element[e] = Main.Control.Types.Element(newE, 0.0, alpha)
#          println(element[e])

#         rear
          alpha = Array{Float64}(undef,4,3)
          newE = Array{Int64}(undef,4)
          newE[1] = cubicElement[m].corner[3]
          newE[2] = cubicElement[m].corner[4]
          newE[3] = cubicElement[m].corner[9]
          newE[4] = cubicElement[m].corner[8]
          e += 1
          global element[e] = Main.Control.Types.Element(newE, 0.0, alpha)
#          println(element[e])

          alpha = Array{Float64}(undef,4,3)
          newE = Array{Int64}(undef,4)
          newE[1] = cubicElement[m].corner[3]
          newE[2] = cubicElement[m].corner[9]
          newE[3] = cubicElement[m].corner[7]
          newE[4] = cubicElement[m].corner[8]
          e += 1
          global element[e] = Main.Control.Types.Element(newE, 0.0, alpha)
#          println(element[e])

#         left
          alpha = Array{Float64}(undef,4,3)
          newE = Array{Int64}(undef,4)
          newE[1] = cubicElement[m].corner[4]
          newE[2] = cubicElement[m].corner[9]
          newE[3] = cubicElement[m].corner[8]
          newE[4] = cubicElement[m].corner[5]
          e += 1
          myE = Main.Control.Types.Element(newE, 0.0, alpha)
          global element[e] = Main.Control.Types.Element(newE, 0.0, alpha)
#          println(element[e])

          alpha = Array{Float64}(undef,4,3)
          newE = Array{Int64}(undef,4)
          newE[1] = cubicElement[m].corner[4]
          newE[2] = cubicElement[m].corner[1]
          newE[3] = cubicElement[m].corner[9]
          newE[4] = cubicElement[m].corner[5]
          e += 1
          myE = Main.Control.Types.Element(newE, 0.0, alpha)
          global element[e] = Main.Control.Types.Element(newE, 0.0, alpha)
#          println(element[e])

#         top
          alpha = Array{Float64}(undef,4,3)
          newE = Array{Int64}(undef,4)
          newE[1] = cubicElement[m].corner[9]
          newE[2] = cubicElement[m].corner[7]
          newE[3] = cubicElement[m].corner[5]
          newE[4] = cubicElement[m].corner[6]
          e += 1
          myE = Main.Control.Types.Element(newE, 0.0, alpha)
          global element[e] = Main.Control.Types.Element(newE, 0.0, alpha)
#          println(element[e])

          alpha = Array{Float64}(undef,4,3)
          newE = Array{Int64}(undef,4)
          newE[1] = cubicElement[m].corner[9]
          newE[2] = cubicElement[m].corner[7]
          newE[3] = cubicElement[m].corner[8]
          newE[4] = cubicElement[m].corner[5]
          e += 1
          myE = Main.Control.Types.Element(newE, 0.0, alpha)
          global element[e] = Main.Control.Types.Element(newE, 0.0, alpha)
#          println(element[e])

#         bottom
          alpha = Array{Float64}(undef,4,3)
          newE = Array{Int64}(undef,4)
          newE[1] = cubicElement[m].corner[1]
          newE[2] = cubicElement[m].corner[2]
          newE[3] = cubicElement[m].corner[3]
          newE[4] = cubicElement[m].corner[9]
          e += 1
          myE = Main.Control.Types.Element(newE, 0.0, alpha)
          global element[e] = Main.Control.Types.Element(newE, 0.0, alpha)
#          println(element[e])

          alpha = Array{Float64}(undef,4,3)
          newE = Array{Int64}(undef,4)
          newE[1] = cubicElement[m].corner[3]
          newE[2] = cubicElement[m].corner[4]
          newE[3] = cubicElement[m].corner[1]
          newE[4] = cubicElement[m].corner[9]
          e += 1
          myE = Main.Control.Types.Element(newE, 0.0, alpha)
          global element[e] = Main.Control.Types.Element(newE, 0.0, alpha)
#          println(element[e])
        end
#        println(element[1])
      catch e
        println("???ERROR in splitCubes: ",e)
        status = -1
      end
    finally
#      println(nElements)
    end
    return status
  end

  function computeAlphaValues()
    status = 0
    alpha = Array{Float64}(undef,4,3)
    try
      try
        for m in 1:nElements
          alpha[1,1] = -1.0 * ((node[element[m].corner[3]].x[2] - node[element[m].corner[2]].x[2]) *
                               (node[element[m].corner[4]].x[3] - node[element[m].corner[2]].x[3]) -
                               (node[element[m].corner[4]].x[2] - node[element[m].corner[2]].x[2]) *
                               (node[element[m].corner[3]].x[3] - node[element[m].corner[2]].x[3]))
          alpha[1,2] = ((node[element[m].corner[3]].x[1] - node[element[m].corner[2]].x[1]) *
                        (node[element[m].corner[4]].x[3] - node[element[m].corner[2]].x[3]) -
                        (node[element[m].corner[4]].x[1] - node[element[m].corner[2]].x[1]) *
                        (node[element[m].corner[3]].x[3] - node[element[m].corner[2]].x[3]))
          alpha[1,3] = -1.0 * ((node[element[m].corner[3]].x[1] - node[element[m].corner[2]].x[1]) *
                               (node[element[m].corner[4]].x[2] - node[element[m].corner[2]].x[2]) -
                               (node[element[m].corner[4]].x[1] - node[element[m].corner[2]].x[1]) *
                               (node[element[m].corner[3]].x[2] - node[element[m].corner[2]].x[2]))

          alpha[2,1] = ((node[element[m].corner[3]].x[2] - node[element[m].corner[1]].x[2]) *
                        (node[element[m].corner[4]].x[3] - node[element[m].corner[1]].x[3]) -
                        (node[element[m].corner[4]].x[2] - node[element[m].corner[1]].x[2]) *
                        (node[element[m].corner[3]].x[3] - node[element[m].corner[1]].x[3]))
          alpha[2,2] = -1.0 * ((node[element[m].corner[3]].x[1] - node[element[m].corner[1]].x[1]) *
                               (node[element[m].corner[4]].x[3] - node[element[m].corner[1]].x[3]) -
                               (node[element[m].corner[4]].x[1] - node[element[m].corner[1]].x[1]) *
                               (node[element[m].corner[3]].x[3] - node[element[m].corner[1]].x[3]))
          alpha[2,3] = ((node[element[m].corner[3]].x[1] - node[element[m].corner[1]].x[1]) *
                        (node[element[m].corner[4]].x[2] - node[element[m].corner[1]].x[2]) -
                        (node[element[m].corner[4]].x[1] - node[element[m].corner[1]].x[1]) *
                        (node[element[m].corner[3]].x[2] - node[element[m].corner[1]].x[2]))

          alpha[3,1] = -1.0 * ((node[element[m].corner[2]].x[2] - node[element[m].corner[1]].x[2]) *
                               (node[element[m].corner[4]].x[3] - node[element[m].corner[1]].x[3]) -
                               (node[element[m].corner[4]].x[1] - node[element[m].corner[1]].x[1]) *
                               (node[element[m].corner[2]].x[3] - node[element[m].corner[1]].x[3]))
          alpha[3,2] = ((node[element[m].corner[2]].x[1] - node[element[m].corner[1]].x[1]) *
                        (node[element[m].corner[4]].x[3] - node[element[m].corner[1]].x[3]) -
                        (node[element[m].corner[4]].x[1] - node[element[m].corner[1]].x[1]) *
                        (node[element[m].corner[2]].x[3] - node[element[m].corner[1]].x[3]))
          alpha[3,3] = -1.0 * ((node[element[m].corner[2]].x[1] - node[element[m].corner[1]].x[1]) *
                               (node[element[m].corner[4]].x[2] - node[element[m].corner[1]].x[2]) -
                               (node[element[m].corner[4]].x[1] - node[element[m].corner[1]].x[1]) *
                               (node[element[m].corner[2]].x[2] - node[element[m].corner[1]].x[2]))

          alpha[4,1] = ((node[element[m].corner[2]].x[2] - node[element[m].corner[1]].x[2]) *
                        (node[element[m].corner[3]].x[3] - node[element[m].corner[1]].x[3]) -
                        (node[element[m].corner[3]].x[2] - node[element[m].corner[1]].x[2]) *
                        (node[element[m].corner[2]].x[3] - node[element[m].corner[1]].x[3]))
          alpha[4,2] = -1.0 * ((node[element[m].corner[4]].x[1] - node[element[m].corner[1]].x[1]) *
                               (node[element[m].corner[3]].x[3] - node[element[m].corner[1]].x[3]) -
                               (node[element[m].corner[3]].x[1] - node[element[m].corner[1]].x[1]) *
                               (node[element[m].corner[2]].x[3] - node[element[m].corner[1]].x[3]))
          alpha[4,3] = ((node[element[m].corner[2]].x[1] - node[element[m].corner[1]].x[1]) *
                        (node[element[m].corner[3]].x[2] - node[element[m].corner[1]].x[2]) -
                        (node[element[m].corner[3]].x[1] - node[element[m].corner[1]].x[1]) *
                        (node[element[m].corner[2]].x[2] - node[element[m].corner[1]].x[2]))

          element[m].alpha = alpha
        end
      catch e
        println("???ERROR in computeAlphaValues: ",e)
        status = -1
      end
    finally
    end
    return status
  end

  function initializeStates()
    status = 0
    try
      try
        global state = Array{Main.Control.Types.State}(undef,nNodes)
        for i in 1:nNodes
          global state[i] = Main.Control.Types.State(0.0)
        end
      catch e
        println("???ERROT in initializeStates: ", e)
        status = 1
      end
    finally
    end
    return status
  end

  function initializeTemperatures(aT :: Float64)
    status = 0
    try
      try
        for i in 1:nNodes
          global state[i].temperature=aT
        end
      catch e
        println("???ERROR in initializeTemperatures: ",e)
        status = 1
      end
    finally
    end
    return status
  end

  function fillLabdaMatrix()
    status = 0
    try
      try
        for i in 1:3
          for j in 1:3
            global labda[i,j] = 1.75
          end
        end
      catch e
        println("???ERROR in fillLabdaMatrix")
        status = -1
      end
    finally
    end
    return status
  end

  function prepare(aFemId :: Int64)
    status = 0
    GR
    try
      try
        println("Creating nodes")
        status = createNodes()
        if status == 0
          println("Adding center nodes")
          addCenterNodes()
        end
#        println(status)
        if status == 0
          println("Creating cubic elements")
          status = createCubicElements()
#          plotCubicElements()
        end
        if status == 0
#          println("Storing nodes")
#          status = Main.Control.DataManager.storeNodes(aFemId,node)
        end
#        println(status)
        if status == 0
          println("Splitting elements")
          status = splitCubes()
#          plotElements()
        end
        if status == 0
#          println("Storing elements")
#          status = Main.Control.DataManager.storeElements(aFemId,element)
        end
#        exit(0)
#        println(status)
        if status == 0
          println("Computing volumes")
          status = volumeOfElement()
        end
        if status == 0
          println("Computing alpha")
          status = computeAlphaValues()
        end
        if status == 0
          println("Filling labda matrix")
          status = fillLabdaMatrix()
        end
        if status == 0
          println("Initializing states")
          status = initializeStates()
        end
      catch e
        println("???ERROR in FEM.prepare: ",e)
      end
    finally
      if status != 0
        println("???ERROR in FEM.prepare: status=",status)
      end
    end
    return status
  end

  function fillMatrix()
    status = 0
#    println(nElements)
#    println(nNodes)
#    println(nXY)
    global matrixA = BandedMatrix(Zeros(nNodes,nNodes), (bandWidth,bandWidth))
    global vectorB = zeros(Float64, nNodes)
#    println(typeof(vectorB))
    try
      try
        for e in 1:nElements
          v36 = 36.0 * element[e].volume
          for k in 1:size(element[e].corner, 1)
            for l in 1:1:size(element[e].corner, 1)
              u = 0.0
              for p in 1:3
                for q in 1:3
                  u += labda[p,q] * element[e].alpha[l,p] * element[e].alpha[k,q]
                end
              end
              u = u / v36

#              if k == l
                v = heatCapacity * element[e].volume / 4.0
#              else
#                v = heatCapacity * element[e].volume / 20.0
#              end
#              println(element[e].corner[k], "  ", element[e].corner[l])
              global matrixA[element[e].corner[k], element[e].corner[l]] += u + v/timing.timeStep
              global vectorB[element[e].corner[k]] += v * state[element[e].corner[l]].temperature / timing.timeStep
#               println(typeof(vectorB))
#               println(typeof(temp))
#               exit(0)
            end
          end
        end
      catch e
        println("???ERROR in FEM.fillMatrix: ",e)
        status = -1
      end
    finally
    end
    return status
  end

  function setFixedValues(aTemp :: Float64)
    status = 0
    try
      try
        for j in 1:nNodes
#          println(j)
          if abs(node[j].x[1] - xCoord[1]) < 1.0e-4 && abs(node[j].x[3] - zCoord[size(zCoord,1)]) < 1.0e-4
            fixed = j
            tFixed = 100.0
            for i in max(1,fixed-bandWidth):min(nNodes,fixed+bandWidth)
              global matrixA[fixed,i] = 0.0
            end
            global matrixA[fixed,fixed] = 1.0
            global vectorB[fixed] = tFixed
          end

          aTemp = 10.0
          if abs(node[j].x[3] - zCoord[1]) < 1.0e-4
            fixed = j
            for i in max(1,fixed-bandWidth):min(nNodes,fixed+bandWidth)
              global matrixA[fixed,i] = 0.0
            end
            global matrixA[fixed,fixed] = 1.0
            global vectorB[fixed] = aTemp
          end
        end
      catch e
        println("???ERROR in FEM.setFixedValues: ", e)
        status = 1
      end
    finally
    end
    return status
  end

  function solveEquations()
    status = 0
    try
      try
#        a = BandedMatrix(Zeros(nNodes,nNodes), (bandWidth,bandWidth))
#        b = Array{Float64}(undef,size(vectorB,1))
#        x = Array{Float64}(undef,size(vectorB,1))
#        a[:,:]=matrixA[:,:]
    #    println(vectorB)
#        b[:]=vectorB[:]
         temp = matrixA \ vectorB
         for i in 1:size(temp,1)
           global state[i].temperature = temp[i]
         end
#        x = a * temp
#        x[:] -= b[:]
#      println(x)
  #      exit(0)
      catch e
        println("???ERROR in FEM.solveEquations: ",e)
        status = 1
      end
    finally
    end
    return status
  end

  function adaptTiming()
    status = 0
    try
      try
        global timing.previousTime = timing.time
        newTime = timing.time + Dates.Second(timing.timeStep)
        if newTime < timing.outputDateTime
          global timing.time = newTime
        else
          dt = convert(Dates.Second, Dates.Period(timing.outputDateTime - timing.time))
          global timing.time = timing.outputDateTime
          global timing.outputRequired = true
        end
      catch e
        println("???ERROR in adaptTiming: ", e)
        status = 1
      end
    finally
    end
    return status
  end

  function process(aMeteo :: Array{Main.Control.Types.Meteo}, aScenarioId :: Int64, aStartTime :: DateTime, aEndTime :: DateTime, aMaxTimeStep :: Float64)
    status = 0
    try
      try
        global timing = Main.Control.Types.Timing(aStartTime, aEndTime, aMaxTimeStep, aMaxTimeStep, aStartTime+Dates.Day(1), false)
        status = initializeTemperatures(10.0)
#        s1 = @sprintf("%7.2f",temp[1])
#        s2 = @sprintf("%7.2f",temp[2])
#        s3 = @sprintf("%7.2f",temp[3])
#        s4 = @sprintf("%7.2f",temp[4])
#        s5 = @sprintf("%7.2f",temp[5])
#        s6 = @sprintf("%7.2f",temp[6])
#        s7 = @sprintf("%7.2f", temp[7])
#        s8 = @sprintf("%7.2f", temp[size(temp,1)])
#        println("0",s1,s2,s3,s4,s5,s6,s7,s8)

        if status == 0
          while timing.time < aEndTime
            status = adaptTiming()
            s0 = Dates.format(timing.time, "yyyy-mm-dd HH:MM:SS  ")
            d =Dates.dayofyear(timing.time)
            tTop = 0.5 * (aMeteo[d].minTemp + aMeteo[d].maxTemp)
#            tTop = 10.0 + 10.0 * sinpi(2.0 * d / 365.0)
            println(s0)

            if status == 0
              for i in 1:4
                global state[i].temperature = tTop
              end
              status = fillMatrix()
            end

            if status == 0
              status = setFixedValues(tTop)
            end
            if status == 0
              status = solveEquations()
            end
            if status == 0
              if timing.outputRequired
                status = Main.Control.DataManager.storeStates(aScenarioId, timing.outputDateTime, state)
                global timing.outputRequired = false
                global timing.outputDateTime += Dates.Day(1)
              end
            end
          end
        end
      catch e
        println("???ERROR in FEM.prcoess: ",e)
        status = -1
      end
    finally
    end
    return status
  end

end
