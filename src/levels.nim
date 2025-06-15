import polycore
import sequtils
import seqmath
import math
import sugar
import arraymancer as arrman
import arraymancer/tensor/private/p_accessors


type
  Level = object
    layout: Tensor[int]
    legend: seq[CellObj]
  World = seq[Level]

let test* = Level(
  layout: [
    [2,  1,  0,  0,  0,  1],
    [0,  1,  0,  1,  0,  1],
    [0,  1,  0,  1,  0,  1],
    [0,  1,  0,  1,  0,  1],
    [0,  1,  0,  1,  0,  1],
    [0,  0,  0,  1,  0,  3]
  ].toTensor(),
  legend: @[
    makeSpace(), makeWall(), makePlayer(), makeTarget() # replace makeSpace() with a normal white rectangle in mazeInit()
  ])