using CSV
using DataFrames
rootingDepth = -0.43
fileName = "/home/wesseling/DataDisk/Wesseling/Work/Warmteleiding/DataDeltares/sim_1c1.csv"
dataRead = CSV.read(fileName, DataFrame)

drz = -0.43
node = 1
while node < size(dataRead,1)
  global node += 1
  dz = dataRead[node-1,"Y"] - dataRead[node,"Y"]
  if drz > dataRead[node,"Y"]
    dz = dataRead[node-1,"Y"] - drz
    global node = size(dataRead,1)
  end
  println(node-1,"   ", dataRead[node,"Y"],"    ",dz)
end

println("Finished")
