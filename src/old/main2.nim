import nico
import sequtils
import random
import sugar

var mazeDebug: bool

const # These play into the maze generation and movement logic
    PASSABLE = true
    IMPASSABLE = false

const # Dimensional labels, carried over from the JS Canvas version
  X = 0
  Y = 1
  Z = 2
  W = 3

const # Maze parameters
  SpaceChance = 0.5
  DefaultSize = 2
  Dimensions = 4

template NDimArray(dims, length: int, kind: untyped): untyped =
  when dims > 0:
    array[length, NDimArray(dims - 1, length, kind)]
  else:
    kind

type nArray = NDimArray(Dimensions, DefaultSize, bool)

var # Arrays that play into the creation of the maze.
  maze: nArray
  size = repeat(DefaultSize, Dimensions)
  playerPosition = repeat(0, Dimensions)

let # Board widths (unnecessary?)
  slotWidth = 16
  slotHeight = 16

let # Colors
  bgColor = 0 # black
  wallColor = 16 # red
  spaceColor = 112 # white
  playerColor = 80 # blue
  goalColor = 48 # green

proc boardHeight(): int =
  return ((size[Y] + 1) * size[Z] - 1) * slotHeight

proc boardWidth(): int =
  return ((size[X] + 1) * size[W] - 1) * slotWidth

proc cornerX(x, y, z, w: int): int =
  return (x + w * (size[X] + 1)) * slotWidth

proc cornerY(x, y, z, w: int): int =
  return (y + z * (size[Y] + 1)) * slotHeight

proc drawBoard() =
  setColor bgColor
  boxfill(0, 0, boardWidth(), boardHeight())

  if mazeDebug: echo "DRAW COORDS:"
  for x in 0 ..< size[X]:
    for y in 0 ..< size[Y]:
      for z in 0 ..< size[Z]:
        for w in 0 ..< size[W]:
          if maze[x][y][z][w] == PASSABLE:
            setColor spaceColor
          else:
            setColor wallColor
          
          if @[x, y, z, w] == map(size, (i) => i - 1):
            setColor goalColor
          if mazeDebug:
            echo (x, y, z, w), ": ", (x: cornerX(x, y, z, w), y: cornerY(x, y, z, w))
          
          boxfill(cornerX(x, y, z, w), cornerY(x, y, z, w), slotWidth, slotHeight)

  let playerX = cornerX(playerPosition[X], playerPosition[Y],
                        playerPosition[Z], playerPosition[W])

  let playerY = cornerY(playerPosition[X], playerPosition[Y],
                        playerPosition[Z], playerPosition[W])

  setColor playerColor
  boxfill(playerX, playerY, slotWidth, slotHeight)

proc attemptToMove(xDifference, yDifference, zDifference, wDifference: int) =
  # Attempt to move the player. Will succeed if the move is in-bounds and the space is passable.

  if ((0 <= playerPosition[X] + xDifference and playerPosition[X] + xDifference < size[X]) and
      (0 <= playerPosition[Y] + yDifference and playerPosition[Y] + yDifference < size[Y]) and
      (0 <= playerPosition[Z] + zDifference and playerPosition[Z] + zDifference < size[Z]) and
      (0 <= playerPosition[W] + wDifference and playerPosition[W] + wDifference < size[W])):

    if maze[playerPosition[X] + xDifference][playerPosition[Y] + yDifference][playerPosition[Z] + zDifference][playerPosition[W] + wDifference] == PASSABLE:

      playerPosition[X] += xDifference
      playerPosition[Y] += yDifference
      playerPosition[Z] += zDifference
      playerPosition[W] += wDifference

proc markReached(reached: var nArray, x, y, z, w: int) = #2.2
  # Recursive helper function to mark all slots reachable from a given
  # slot. Used in seeing if the maze is navigable.
  reached[x][y][z][w] = true

  if x - 1 >= 0:
    if maze[x - 1][y][z][w] == PASSABLE and not reached[x - 1][y][z][w]:
      markReached(reached, x - 1, y, z, w)

  if x + 1 < size[X]:
    if maze[x + 1][y][z][w] == PASSABLE and not reached[x + 1][y][z][w]:
      markReached(reached, x + 1, y, z, w)

  if y - 1 >= 0:
    if maze[x][y - 1][z][w] == PASSABLE and not reached[x][y - 1][z][w]:
      markReached(reached, x, y - 1, z, w)

  if y + 1 < size[Y]:
    if maze[x][y + 1][z][w] == PASSABLE and not reached[x][y + 1][z][w]:
      markReached(reached, x, y + 1, z, w)

  if z - 1 >= 0:
    if maze[x][y][z - 1][w] == PASSABLE and not reached[x][y][z - 1][w]:
      markReached(reached, x, y, z - 1, w)

  if z + 1 < size[Z]:
    if maze[x][y][z + 1][w] == PASSABLE and not reached[x][y][z + 1][w]:
      markReached(reached, x, y, z + 1, w)

  if w - 1 >= 0:
    if maze[x][y][z][w - 1] == PASSABLE and not reached[x][y][z][w - 1]:
      markReached(reached, x, y, z, w - 1)

  if w + 1 < size[W]:
    if maze[x][y][z][w + 1] == PASSABLE and not reached[x][y][z][w + 1]:
      markReached(reached, x, y, z, w + 1)

proc mazeIsSolveable(): bool = #2.1
  # Method to determine if a given maze is solveable.
  var reached: nArray
  for x in 0 ..< size[X]:
    for y in 0 ..< size[Y]:
      for z in 0 ..< size[Z]:
        for w in 0 ..< size[W]:
          reached[x][y][z][w] = false

  markReached(reached, 0, 0, 0, 0)
  return reached[size[X] - 1][size[Y] - 1][size[Z] - 1][size[W] - 1]

proc generateMaze() = #2
  # Generate a solveable maze. The original eighth-grade program did
  # not check to see if the generated maze was solveable.
  for x in 0 ..< size[X]:
    for y in 0 ..< size[Y]:
      for z in 0 ..< size[Z]:
        for w in 0 ..< size[W]:
          if rand(1.0) < SpaceChance:
            maze[x][y][z][w] = PASSABLE
          else:
            maze[x][y][z][w] = IMPASSABLE

  maze[0][0][0][0] = PASSABLE
  maze[size[X] - 1][size[Y] - 1][size[Z] - 1][size[W] - 1] = PASSABLE

  if not mazeIsSolveable():
    generateMaze()

proc mazeInit() =
  mazeDebug = true
  playerPosition = repeat(0, Dimensions)
  generateMaze()
  drawBoard()
  mazeDebug = false

proc testWin() =
  # Test to see if the player has won, and, if so,
  # congratulate the player and create a new maze.
  if playerPosition == size.map((n) => n - 1):
    mazeInit()

proc mouseClicked(dt: float32) =
  if mousebtn 0:
    let
      (clickX, clickY) = mouse()
      
      x = clickX div slotWidth mod (size[X] + 1)
      y = clickY div slotHeight mod (size[Y] + 1)
      z = clickY div slotHeight div (size[Y] + 1)
      w = clickX div slotWidth div (size[X] + 1)

    if ((0 <= x and x < size[X]) and
        (0 <= y and y < size[Y]) and
        (0 <= z and z < size[Z]) and
        (0 <= w and w < size[W])):
          
          let
            xDifference = x - playerPosition[X]
            yDifference = y - playerPosition[Y]
            zDifference = z - playerPosition[Z]
            wDifference = w - playerPosition[W]

          if (abs(xDifference) +
              abs(yDifference) +
              abs(zDifference) +
              abs(wDifference) < 2):
            attemptToMove(xDifference, yDifference,
                          zDifference, wDifference)
            testWin()

proc gameInit() =
  randomize()
  setPalette loadPaletteFromGPL "RGB Gradients.gpl"
  mazeInit()

nico.init("CubixThree", "polycore")
nico.createWindow("polycore", boardWidth(), boardHeight(), 1, false)
nico.run(gameInit, mouseClicked, drawBoard)
