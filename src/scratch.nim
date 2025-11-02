import
  nico, # Well hello little engine. What's your name?
  sequtils, arraymancer as arrman,
  math, seqmath,
  algorithm, sets,
  random,
  sugar,
  polycore

randomize()

var
  maxLen = 6
  dims = 6 #rand(2..6)
  size = newSeq[int](dims)

for i, x in size:
  size[i] = 6#rand(1..maxLen)

echo size

var maze: Tensor[int] = arrman.zeros[int](size)

var
  viewDimX: int = 0
  viewDimY: int = 1
  viewIndex: seq[int] = repeat(1, dims)
  mazeView: Tensor[int]

viewIndex[viewDimX] = size[viewDimX]-1
viewIndex[viewDimY] = size[viewDimY]-1
echo viewIndex
mazeView = squeeze(maze[viewIndex])



echo maze[viewIndex]

# nico.init("CubixThree", "polycore")
