import nico
import sequtils
from math import floor
import random


const # These play into the maze generation and movement logic
    PASSABLE = true
    IMPASSABLE = false


const # Dimensional labels, carried over from the JS Canvas version
  X = 0
  Y = 1
  Z = 2
  W = 3


const # Maze parameters
  probabilityPassable = 0.5
  DEFAULT_SIZE = 4
  DIMENSION = 4


var # Arrays that play into the creation of the maze.
  size = repeat(DEFAULT_SIZE, DIMENSION)
  playerPosition = repeat(0, DIMENSION)

# iterator name(a): return type

type nArray = seq[seq[seq[seq[bool]]]]


var maze: nArray
for i in 0 ..< size[X]:
  # maze[i] = []
  for j in 0 ..< size[Y]:
    # maze[i][j] = []
    for k in 0 ..< size[Z]:
      # maze[i][j][k] = []
      for l in 0 ..< size[W]:
        maze[i][j][k][l] = PASSABLE


const # Board widths (unnecessary?)
  borderWidth = 40
  borderHeight = 40
  slotWidth = 20
  slotHeight = 20


const # Colors
  bgColor = 0 # black
  wallColor = 16 # red
  spaceColor = 112 # white
  playerColor = 80 # blue
  goalColor = 48 # green


proc boardHeight(): int =
  # Calculate the height of the board, in pixels.
  return 2 * borderHeight + (size[Y] + 1) * size[Z] * slotHeight


proc boardWidth(): int =
  # Calculate the width of the board, in pixels.
  return 2 * borderWidth + ((size[X] + 1) * size[W]) * slotWidth


proc cornerX(x, y, z, w: int): int =
  # Calculate the x coordinate of the lower lefthand corner of a square 
  # representing a slot in the maze.
  return borderWidth + (x + w * (size[X] + 1)) * slotWidth


proc cornerY(x, y, z, w: int): int =
  # Calculate the y coordinate of the lower lefthand corner of a square
  # representing a slot in the maze.
  return boardHeight() - (borderHeight + (y + z * (size[Y] + 1) + 2) * slotHeight)


proc drawBoard() = #3
  # Draw the board on the screen.
  setColor bgColor
  boxfill(0, 0, boardWidth(), boardHeight())

  for i in 0 ..< size[X]:
    for j in 0 ..< size[Y]:
      for k in 0 ..< size[Z]:
        for l in 0 ..< size[W]:
          if maze[i][j][k][l] == PASSABLE:
            setColor spaceColor
          else:
            setColor wallColor
                  
          if ((i == size[X] - 1) and
              (j == size[Y] - 1) and
              (k == size[Z] - 1) and
              (l == size[W] - 1)):
                setColor goalColor
          
          boxfill(cornerX(i, j, k, l), cornerY(i, j, k, l), slotWidth, slotHeight)

  let playerX = cornerX(playerPosition[X], playerPosition[Y],
                        playerPosition[Z], playerPosition[W])

  let playerY = cornerY(playerPosition[X], playerPosition[Y],
                        playerPosition[Z], playerPosition[W])

  setColor playerColor
  boxfill(playerX, playerY, slotWidth, slotHeight)


proc attemptToMove(xDifference, yDifference, zDifference, wDifference: int) =
  # Attempt to move the player by a given vector relative to his present
  # position. Will succeed if the move is to a legal board space and the
  # space is passable.

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
    for i in 0 ..< size[X]:
        # reached[i] = []
        for j in 0 ..< size[Y]:
            # reached[i][j] = []
            for k in 0 ..< size[Z]:
                # reached[i][j][k] = []
                for l in 0 ..< size[W]:
                    reached[i][j][k][l] = false

    markReached(reached, 0, 0, 0, 0)
    return reached[size[X] - 1][size[Y] - 1][size[Z] - 1][size[W] - 1]


proc generateMaze() = #2
    # Generate a solveable maze. The original eighth-grade program did
    # not check to see if the generated maze was solveable.

    for i in 0 ..< size[X]:
        for j in 0 ..< size[Y]:
            for k in 0 ..< size[Z]:
                for l in 0 ..< size[W]:
                    # The greatest mistake in the history of mankind:
                    if rand(0.5) < probabilityPassable:
                        maze[i][j][k][l] = PASSABLE
                    else:
                        maze[i][j][k][l] = IMPASSABLE

    maze[0][0][0][0] = PASSABLE
    maze[size[X] - 1][size[Y] - 1][size[Z] - 1][size[W] - 1] = PASSABLE

    if not mazeIsSolveable():
        generateMaze()


proc onInit() =
  generateMaze()
  drawBoard()


proc testWin() =
    # Test to see if the player has won, and, if so,
    # congratulate the player and create a new maze.

    if (playerPosition[X] == size[X] - 1 and
        playerPosition[Y] == size[Y] - 1 and
        playerPosition[Z] == size[Z] - 1 and
        playerPosition[W] == size[W] - 1):
        print("Congratulations, you've solved the maze!")
        onInit()


proc mouseClicked(dt: float32) =
  if mousebtn 0:
    let
      (clickX, clickY) = mouse()
      x = floor((clickX - borderWidth) / slotWidth) mod (size[X] + 1)
      y = (floor((boardHeight() - borderHeight - clickY) / slotHeight) mod (size[Y] + 1)) - 1
      z = floor(floor((boardHeight() - borderHeight - clickY) / slotHeight) / float(size[Y] + 1))
      w = floor((floor((clickX - borderWidth) / slotWidth)) / float(size[X] + 1))

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


nico.init("CubixThree", "polycore")

nico.createWindow("polycore", 512, 512, 1, false)

nico.run(onInit, mouseClicked, drawBoard)
