import nico
import sequtils
import seqmath
import math
import random
import sugar
import arraymancer
import arraymancer/tensor/private/p_accessors


include polycore
using
  pos, vect: Position
  obj: Cell

# import debugs


nico.init("CubixThree", "polycore")
setPalette loadPaletteFromGPL "RGB Gradients.gpl"
randomize()


# TODO: Phase out in favor of n-dimensional tensors.
const # Dimensional labels, carried over from the JS Canvas version
  X = 0
  Y = 1
  Z = 2
  W = 3

var debugs = false


var # Maze parameters
  spaceProb = 0.5
  maxLen = 5
  dims = 4


var size: seq[int]
var maze: Tensor[Cell]

proc randomSize() =
  size = newSeq[int](dims)
  for i in 0..<dims:
    size[i] = rand(2..maxLen)
proc randomPos(): Position = size.map i => rand(0 ..< i)

var
  cellScale: int
  offset: float

proc boardWidth(): int =
  ((size[X] + 1) * size[Z] + 3) * cellScale
  # (((size[x0] + 1) * size[x1] + 3) * size[x2] + 3)...)
proc boardHeight(): int =
  ((size[Y] + 1) * size[W] + 3) * cellScale
  # (((size[y0] + 1) * size[y1] + 3) * size[y2] + 3)...)

proc toCoords(pos): tuple[x: int, y: int] =
  (x: (pos[X] + pos[Z] * (size[X] + 1) + offset) * cellScale,
   y: (pos[Y] + pos[W] * (size[Y] + 1) + offset) * cellScale)
  # (d0 + d1 * (size[D1] + 1) + d2 * (size[D2] + 2))


proc markReached(reached: var Tensor[bool], pos: varargs[int]) =
  # Recursive helper function to mark all cells reachable from the given cell.
  
  #[ var p = toSeq(pos.items)
      atIndexMut(reached, pos, true)
  
    for axis, coord in pos:
      if coord - 1 >= 0:
        p[axis] = coord - 1
      elif coord + 1 < size[axis]:
        p[axis] = coord + 1

      if not maze.atIndex(p).solid and not reached.atIndex(p):
        markReached(reached, p) ]#

  if x - 1 >= 0:
    if not maze[x - 1, y, z, w].solid and not reached[x - 1, y, z, w]:
      markReached(reached, x - 1, y, z, w)

  if x + 1 < size[X]:
    if not maze[x + 1, y, z, w].solid and not reached[x + 1, y, z, w]:
      markReached(reached, x + 1, y, z, w)

  if y - 1 >= 0:
    if not maze[x, y - 1, z, w].solid and not reached[x, y - 1, z, w]:
      markReached(reached, x, y - 1, z, w)

  if y + 1 < size[Y]:
    if not maze[x, y + 1, z, w].solid and not reached[x, y + 1, z, w]:
      markReached(reached, x, y + 1, z, w)

  if z - 1 >= 0:
    if not maze[x, y, z - 1, w].solid and not reached[x, y, z - 1, w]:
      markReached(reached, x, y, z - 1, w)

  if z + 1 < size[Z]:
    if not maze[x, y, z + 1, w].solid and not reached[x, y, z + 1, w]:
      markReached(reached, x, y, z + 1, w)

  if w - 1 >= 0:
    if not maze[x, y, z, w - 1].solid and not reached[x, y, z, w - 1]:
      markReached(reached, x, y, z, w - 1)

  if w + 1 < size[W]:
    if not maze[x, y, z, w + 1].solid and not reached[x, y, z, w + 1]:
      markReached(reached, x, y, z, w + 1)

proc possible(): bool =
  var reached = newTensor[bool](size)
  markReached(reached, player.pos[X], player.pos[Y], player.pos[Z], player.pos[W])
  return reached.atIndex(target.pos)

proc generateMaze() =
  echo size
  randomSize()
  player.pos = randomPos()
  target.pos = randomPos()

  maze = newTensor[Cell](size)
  for x in 0 ..< size[X]:
    for y in 0 ..< size[Y]:
      for z in 0 ..< size[Z]:
        for w in 0 ..< size[W]:
          if rand(1.0) < spaceProb:
            maze[x, y, z, w] = space
          else:
            maze[x, y, z, w] = wall

  maze.atIndex(player.pos) = space
  maze.atIndex(target.pos) = space
  echo (player: player.pos, target: target.pos)

  if not possible():
    echo "Impossible maze. Trying again:"
    generateMaze()


proc draw(obj, pos) =
  let (x, y) = pos.toCoords
  setColor obj.color
  boxfill(x, y, cellScale, cellScale)

proc drawBoard() =
  setColor 0
  boxfill(0, 0, screenWidth, screenHeight)

  for x in 0 ..< size[X]:
    for y in 0 ..< size[Y]:
      for z in 0 ..< size[Z]:
        for w in 0 ..< size[W]:
          if maze[x, y, z, w] == space:
            draw space, @[x, y, z, w]
          else:
            draw wall, @[x, y, z, w]
  
  draw target, target.pos
  draw player, player.pos


proc toPos(cx, cy: int): Position =
  let
    x = (cx div cellScale - offset) mod (size[X]+1)
    y = (cy div cellScale - offset) mod (size[Y]+1)
    z = (cx div cellScale - offset) div (size[X]+1)
    w = (cy div cellScale - offset) div (size[Y]+1)
  
  result = @[x, y, z, w]

proc toPos(coords: (int, int)): Position = toPos(coords[0], coords[1])


proc attemptToMove(obj, vect) =
  var moveResult = eAdd(obj.pos, vect)
  
  for (s, r) in zip(size, moveResult):
    echo (width: s, position: r)
    if r notin 0 ..< s:
      echo "Out of bounds: width - pos = ", s - abs(r), "! Thats no good..."
      return

  if maze.atIndex(moveResult).solid == false:
    obj.pos = moveResult


proc moveBy(obj; dim: Natural, amt: int) =
  var vector = newSeq[int](dims)
  vector[dim-1] = amt
  echo eAdd(vector, obj.pos), " - ", vector
  obj.attemptToMove vector

proc mouseClicked() =
  # The actual position of the mouse
  let clickPos = mouse().toPos()
  # The relative position of the mouse to the player
  let moveVect = eSub(clickPos, player.pos)
  echo clickPos, " - ", moveVect

  # The player can only move one space at a time, no diagonals.
  # This checks if the vector only contains a single 1 of either sign.
  # NOTE: I might add a Power that lets the player move further,
  # so this value may need to become a property tied to Mobs/Players.
  if sum(abs moveVect) <= 1:
    player.attemptToMove moveVect

var shiftVal = 1
proc arrowAction() =
  # Dimension shifting
  # min = 1
  # max = Dims
  if keyp(K_LSHIFT):
    shiftVal += 2
    if shiftVal > dims:
      shiftVal = 1
  elif keyp(K_RSHIFT):
    shiftVal -= 2
    if shiftVal < 1:
      shiftVal = dims - 1

  # Movement
  if K_RIGHT.keypr 10: player.moveBy shiftVal, 1
  elif K_LEFT.keypr 10: player.moveBy shiftVal, -1

  if shiftVal != dims:
    if K_DOWN.keypr 10: player.moveBy (shiftVal + 1), 1
    elif K_UP.keypr 10: player.moveBy (shiftVal + 1), -1


proc getAllCoords*() =
  echo "DRAW COORDS:"
  for x in 0 ..< size[X]:
    for y in 0 ..< size[Y]:
      for z in 0 ..< size[Z]:
        for w in 0 ..< size[W]:
          echo (x,y,z,w), ": ", @[x,y,z,w].toCoords()

proc checkRightPositions*() =
  let mouseCoordsA = mouse()
  echo "Mouse coords: ", mouseCoordsA
  var mousePos = mouseCoordsA.toPos()
  echo "Mouse coords as pos: ", mousePos

  let mazeItem =
    if mousePos == player.pos: "player"
    elif mousePos == target.pos: "target"
    else:
      try:
        if maze.atIndex(mousePos) == space: "space"
        else: "wall"
      except: "unknown"
  
  echo "Item at mousePos: ", mazeItem

  let mouseCoordsB = mousePos.toCoords()
  echo "Mouse pos back to coords: ", mouseCoordsB
  echo "Mouse coords rounded: ",
    (mouseCoordsB.x - (mouseCoordsB.x mod cellScale),
     mouseCoordsB.y - (mouseCoordsB.y mod cellScale))
  if
    mouseCoordsA[0] notin mouseCoordsB[0]..mouseCoordsB[0]+cellScale and
    mouseCoordsA[1] notin mouseCoordsB[1]..mouseCoordsB[1]+cellScale:
    echo "...Which is wrong."

proc checkProperScale*() =
  echo "Board size: ", (boardWidth(), boardHeight()), "; ",
       "Screen size: ", (screenWidth, screenHeight)
  
  echo "Maze scale: ", cellScale

  let highestPos = size.eSub(1).toCoords.toPos

  echo "Maze bottom right position: ", highestPos
  echo "Maze shape: ", size.eSub(1)

  let (sizeCoords, highestCoords) = (size.eSub(1).toCoords(), highestPos.toCoords())
  echo "As coordinates: ", (shape: sizeCoords, corner: highestCoords)
  if sizeCoords != highestCoords:
    echo "Not the right amount!"
    echo "Difference: ",
      (sizeCoords.x - highestCoords.x,
       sizeCoords.y - highestCoords.y)

proc winConditions(): bool =
  player.pos == target.pos

proc mazeInit() =
  randomSize()
  shiftVal = 1
  cellScale = 16
  offset = 2
  
  generateMaze()
  nico.setTargetSize(boardWidth(), boardHeight())
  nico.setScreenSize(boardWidth(), boardHeight())
  drawBoard()

proc getInput(dt: float32) =
  if debugs:
    if keyp(K_C): getAllCoords()
    elif keyp(K_F): echo "Current movement plane: ", shiftVal
    elif keyp(K_A): echo "Player at ", player.pos, ", Goal at ", target.pos
    elif keyp(K_S): checkProperScale()

    if keyp(K_LSHIFT) and mousebtnp(0): checkRightPositions()

    if keyp(K_D): debugs = false
  
  elif keyp(K_D): debugs = true


  cellScale += mousewheel()
  if mousewheel() == 1:
    offset /= 2
  elif mousewheel() == -1:
    offset *= 2
  
  if mousebtn(0): mouseClicked()
  else: arrowAction()

  if winConditions() or keyp(K_R): mazeInit()


nico.createWindow("polycore", 128, 128)
nico.run(mazeInit, getInput, drawBoard)
