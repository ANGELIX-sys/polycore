import nico
import sequtils
import seqmath
import math
import random
import sugar

randomize()

var mazeDebug: bool

const # These play into the maze generation and movement logic
    PASSABLE = true
    IMPASSABLE = false

const # Dimensional labels, carried over from the JS Canvas version
  X = 0
  Y = 1
  Z = 2
  W = 3
  V = 4
  U = 5

const # Maze parameters
  SpaceChance = 0.5
  DefaultSize = 2
  Dimensions = 6

template NDimArray(dims, length: int, kind: untyped): untyped =
  # Maybe re-implement this into main for when mazes greater than 6 dimensions are needed?
  # - 7/24/22
  when dims > 0:
    array[length, NDimArray(dims - 1, length, kind)]
  else:
    kind

type
  BoolArray = NDimArray(Dimensions, DefaultSize, bool)
  Position = seq[int]

var maze: BoolArray
var size = repeat(DefaultSize, Dimensions)

proc randomPos(): Position = size.map (i) => rand(i - 1)

# Positions of key items in the maze.
var playerPos, goalPos: Position
var shiftVal = 0

let cellScale = 16

let # Colors
  bgColor = 0 # black
  wallColor = 16 # red
  spaceColor = 112 # white
  playerColor = 80 # blue
  goalColor = 48 # green

# (((size[x0] + 1) * size[x1] + 2) * size[x2] + 3)...) * cellScale
proc boardWidth(): int = # -1 -> +2
  return (size[X] + 1) * (size[Z] + 2) * (size[V] + 3) * cellScale

# (((size[y0] + 1) * size[y1] + 2) * size[y2] + 3)...) * cellScale
proc boardHeight(): int = # -1 -> +2
  return (size[Y] + 1) * (size[W] + 2) * (size[U] + 3) * cellScale

# (x, y, z, w, v, u) => (x + z * (size[X] + 1) + v * (size[Z] + 2))
proc cellX(x, y, z, w, v, u: int): int =
  return (x + z * (size[X] + 1) + v * (size[Z] + 2)) * cellScale

# (x, y, z, w, v, u) => (y + w * (size[Y] + 1) + u * (size[W] + 2))
proc cellY(x, y, z, w, v, u: int): int =
  return (y + w * (size[Y] + 1) + u * (size[W] + 2)) * cellScale

proc drawBoard() = #3
  setColor bgColor
  boxfill(0, 0, boardWidth(), boardHeight())

  if mazeDebug: echo "DRAW COORDS:"
  for x in 0 ..< size[X]:
    for y in 0 ..< size[Y]:
      for z in 0 ..< size[Z]:
        for w in 0 ..< size[W]:
          for v in 0 ..< size[V]:
            for u in 0 ..< size[U]:
              if maze[x][y][z][w][v][u] == PASSABLE:
                setColor spaceColor
              else:
                setColor wallColor
              
              if @[x, y, z, w, v, u] == goalPos:
                setColor goalColor
              
              boxfill(cellX(x, y, z, w, v, u),
                      cellY(x, y, z, w, v, u),
                      cellScale, cellScale)
              
              if mazeDebug:
                echo (x, y, z, w, v, u),
                     " at ",
                     (cellX(x, y, z, w, v, u),
                      cellY(x, y, z, w, v, u))

  let
    playerX = cellX(playerPos[X], playerPos[Y], playerPos[Z],
                    playerPos[W], playerPos[V], playerPos[U])

    playerY = cellY(playerPos[X], playerPos[Y], playerPos[Z],
                    playerPos[W], playerPos[V], playerPos[U])

  setColor playerColor
  boxfill(playerX, playerY, cellScale, cellScale)

proc markReached(reached: var BoolArray, x, y, z, w, v, u: int) = #2.2
  # Recursive helper function to mark all cells reachable from the given cell.
  reached[x][y][z][w][v][u] = true

  if x - 1 >= 0:
    if maze[x - 1][y][z][w][v][u] == PASSABLE and not reached[x - 1][y][z][w][v][u]:
      markReached(reached, x - 1, y, z, w, v, u)

  if x + 1 < size[X]:
    if maze[x + 1][y][z][w][v][u] == PASSABLE and not reached[x + 1][y][z][w][v][u]:
      markReached(reached, x + 1, y, z, w, v, u)

  if y - 1 >= 0:
    if maze[x][y - 1][z][w][v][u] == PASSABLE and not reached[x][y - 1][z][w][v][u]:
      markReached(reached, x, y - 1, z, w, v, u)

  if y + 1 < size[Y]:
    if maze[x][y + 1][z][w][v][u] == PASSABLE and not reached[x][y + 1][z][w][v][u]:
      markReached(reached, x, y + 1, z, w, v, u)

  if z - 1 >= 0:
    if maze[x][y][z - 1][w][v][u] == PASSABLE and not reached[x][y][z - 1][w][v][u]:
      markReached(reached, x, y, z - 1, w, v, u)

  if z + 1 < size[Z]:
    if maze[x][y][z + 1][w][v][u] == PASSABLE and not reached[x][y][z + 1][w][v][u]:
      markReached(reached, x, y, z + 1, w, v, u)

  if w - 1 >= 0:
    if maze[x][y][z][w - 1][v][u] == PASSABLE and not reached[x][y][z][w - 1][v][u]:
      markReached(reached, x, y, z, w - 1, v, u)

  if w + 1 < size[W]:
    if maze[x][y][z][w + 1][v][u] == PASSABLE and not reached[x][y][z][w + 1][v][u]:
      markReached(reached, x, y, z, w + 1, v, u)

  if v - 1 >= 0:
    if maze[x][y][z][w][v - 1][u] == PASSABLE and not reached[x][y][z][w][v - 1][u]:
      markReached(reached, x, y, z, w, v - 1, u)

  if v + 1 < size[W]:
    if maze[x][y][z][w][v + 1][u] == PASSABLE and not reached[x][y][z][w][v + 1][u]:
      markReached(reached, x, y, z, w, v + 1, u)

  if u - 1 >= 0:
    if maze[x][y][z][w][v][u - 1] == PASSABLE and not reached[x][y][z][w][v][u - 1]:
      markReached(reached, x, y, z, w, v, u - 1)

  if u + 1 < size[W]:
    if maze[x][y][z][w][v][u + 1] == PASSABLE and not reached[x][y][z][w][v][u + 1]:
      markReached(reached, x, y, z, w, v, u + 1)

proc possible(): bool =
  # Checks if the maze is possible to solve.
  var reached: BoolArray
  for x in 0 ..< size[X]:
    for y in 0 ..< size[Y]:
      for z in 0 ..< size[Z]:
        for w in 0 ..< size[W]:
          for v in 0 ..< size[V]:
            for u in 0 ..< size[U]:
              reached[x][y][z][w][v][u] = false

  markReached(reached, 0, 0, 0, 0, 0, 0)
  return reached[size[X] - 1][size[Y] - 1][size[Z] - 1][size[W] - 1][size[V] - 1][size[U] - 1]

proc generateMaze() =
  for x in 0 ..< size[X]:
    for y in 0 ..< size[Y]:
      for z in 0 ..< size[Z]:
        for w in 0 ..< size[W]:
          for v in 0 ..< size[V]:
            for u in 0 ..< size[U]:
              if rand(1.0) < SpaceChance:
                maze[x][y][z][w][v][u] = PASSABLE
              else:
                maze[x][y][z][w][v][u] = IMPASSABLE

  maze[playerPos[X]][playerPos[Y]][playerPos[Z]][playerPos[W]][playerPos[V]][playerPos[U]] = PASSABLE
  maze[goalPos[X]][goalPos[Y]][goalPos[Z]][goalPos[W]][goalPos[V]][goalPos[U]] = PASSABLE
  if not possible(): generateMaze()

proc mazeInit() =
  mazeDebug = true
  playerPos = randomPos()
  goalPos = randomPos()
  generateMaze()
  drawBoard()
  mazeDebug = false

proc attemptToMove(pos: var Position, diff: Position) =
  let newMove: Position = eAdd(pos, diff)
  if
    newMove.all M =>
    size.all S =>
    (0..S).contains M:
    
    if maze[newMove[X]][newMove[Y]][newMove[Z]][newMove[W]][newMove[V]][newMove[U]] == PASSABLE:
      pos = newMove
      echo (x: [newMove[X], newMove[Z], newMove[V]],
            y: [newMove[Y], newMove[W], newMove[U]]) # debug

proc moveTo(pos: var Position, dim, amt: int) =
  var vector = newSeq[int](Dimensions)
  vector.insert(amt, dim - 1)
  pos.attemptToMove vector

proc mouseAction() =
  let
    clickX = mouse()[X] div cellScale
    clickY = mouse()[Y] div cellScale
    x = clickX mod (size[X]+1) mod (size[Z]+2)
    y = clickY mod (size[Y]+1) mod (size[W]+2)
    z = clickX div (size[X]+1) mod (size[Z]+2)
    w = clickY div (size[Y]+1) mod (size[W]+2)
    v = clickX div (size[X]+1) div (size[Z]+2)
    u = clickY div (size[Y]+1) div (size[W]+2)
    clickPos: Position = @[x, y, z, w, v, u]
  echo (x: [x, z, v],
        y: [y, w, u]) # debug

  if
    clickPos.all m =>
    size.all s =>
    (0..s).contains m:
    
    let diffVector = eSub(clickPos, playerPos)

    if sum(diffVector.abs) < 2:
      playerPos.attemptToMove diffVector
      if playerPos == goalPos: mazeInit()

proc arrowAction() =
  # Dimension shifting
  if keyp(K_RSHIFT):
    shiftVal += 2
    if shiftVal == Dimensions + 1: shiftVal -= 1
    elif shiftVal > Dimensions: shiftVal = 0
  elif keyp(K_LSHIFT):
    shiftVal -= 2
    if shiftVal == -1: shiftVal += 1
    elif shiftVal < 0: shiftVal = Dimensions
  # Movement
  if K_RIGHT.keypr 10:
    playerPos.moveTo shiftVal, 1
  elif K_LEFT.keypr 10:
    playerPos.moveTo shiftVal, -1
  if K_UP.keypr 10:
    playerPos.moveTo (shiftVal + 1), 1
  elif K_DOWN.keypr 10:
    playerPos.moveTo (shiftVal + 1), -1

proc getAllCoords() =
  echo "DRAW COORDS:"
  echo "BOARD DIMS: ", (boardHeight(), boardWidth())
  for x in 0 ..< size[X]:
    for y in 0 ..< size[Y]:
      for z in 0 ..< size[Z]:
        for w in 0 ..< size[W]:
          for v in 0 ..< size[V]:
            for u in 0 ..< size[U]:
              echo (x,y,z,w,v,u), ": ", (x: cellX(x,y,z,w,v,u), y: cellY(x,y,z,w,v,u))

proc getInput(dt: float32) =
  if keyp(K_S): getAllCoords()
  if 0.mousebtnpr 10: mouseAction()
  arrowAction()

nico.init("CubixThree", "polycore")
nico.createWindow("polycore", boardWidth(), boardHeight(), 1, false)
nico.run(mazeInit, getInput, drawBoard)
