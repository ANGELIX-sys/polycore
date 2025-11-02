import nico
import sequtils, sets
import math, random
# import algorithm
import sugar
import arraymancer
import arraymancer/../tensor/private/p_accessors

import polycore
using
  pos, vect: Position
  obj: Cell

const
  X = 0
  Y = 1
  Z = 2
  W = 3

const
  SpaceChance = 0.5
  MaxSize = 4
  Dimensions = 4

var cellScale = 16

var
  Player = Cell(color: palIndex(0, 0, 255), solid: true)
  Goal = Cell(color: palIndex(0, 255, 0), solid: false)
  Wall = Cell(color: palIndex(255, 0, 0), solid: true)
  Space = Cell(color: palIndex(255, 255, 255), solid: false)

var size = repeat(rand 1..MaxSize, Dimensions)

var maze = newTensor[Cell](size)

for i, c in maze:
  maze.atIndex(i) = new Cell


proc randomPos(): Position =
  map size, i => rand i

# (((size[y0] + 1) * size[y1] + 2) * size[y2] + 3)...) * cellScale
proc boardHeight(): int = # -1 -> +2
  return ((size[Y] + 1) * size[W] - 1) * cellScale

# (((size[x0] + 1) * size[x1] + 2) * size[x2] + 3)...) * cellScale
proc boardWidth(): int = # -1 -> +2
  return ((size[X] + 1) * size[Z] - 1) * cellScale

# (x, y, z, w, v, t) => (x + z * (size[X] + 1) + v * (size[Z] + 2))
proc toCoords(pos: Position): tuple[x: int, y: int] =
  # Get the screen coordinates of an object in the maze.
  return (x: (pos[X] + pos[Z] * (size[X] + 1)) * cellScale,
          y: (pos[Y] + pos[W] * (size[Y] + 1)) * cellScale)

proc draw(obj: Cell) =
  setColor obj.color

  let (x, y) = toCoords(obj.pos)
  boxfill(x, y, cellScale, cellScale)

proc drawBoard() = #3
  setColor 0
  boxfill(0, 0, boardWidth(), boardHeight())

  for x in 0 ..< size[X]:
    for y in 0 ..< size[Y]:
      for z in 0 ..< size[Z]:
        for w in 0 ..< size[W]:
          draw maze.atIndex [x, y, z, w]

proc attemptToMove(diffVector: Position) =
  # Attempt to move the player. Will succeed if the move is in-bounds and the space is passable.
  let moveResult: Position = zip(Player.pos, diffVector).map m => m[0] + m[1]

  if zip(moveResult, size).all (c) => (0 <= c[0]) and (c[0] < c[1]):
    if not maze.atIndex(moveResult).solid:
      Player.pos = moveResult

proc markReached(reached: var Tensor, x, y, z, w: int) = #2.2
  # Recursive helper function to mark all cells reachable from the given cell.
  reached[x, y, z, w] = true

  if x - 1 >= 0:
    if not(maze[x - 1, y, z, w].solid or reached[x - 1, y, z, w]):
      markReached(reached, x - 1, y, z, w)

  if x + 1 < size[X]:
    if not(maze[x + 1, y, z, w].solid or reached[x + 1, y, z, w]):
      markReached(reached, x + 1, y, z, w)

  if y - 1 >= 0:
    if not(maze[x, y - 1, z, w].solid or reached[x, y - 1, z, w]):
      markReached(reached, x, y - 1, z, w)

  if y + 1 < size[Y]:
    if not(maze[x, y + 1, z, w].solid or reached[x, y + 1, z, w]):
      markReached(reached, x, y + 1, z, w)

  if z - 1 >= 0:
    if not(maze[x, y, z - 1, w].solid or reached[x, y, z - 1, w]):
      markReached(reached, x, y, z - 1, w)

  if z + 1 < size[Z]:
    if not(maze[x, y, z + 1, w].solid or reached[x, y, z + 1, w]):
      markReached(reached, x, y, z + 1, w)

  if w - 1 >= 0:
    if not(maze[x, y, z, w - 1].solid or reached[x, y, z, w - 1]):
      markReached(reached, x, y, z, w - 1)

  if w + 1 < size[W]:
    if not(maze[x, y, z, w + 1].solid or reached[x, y, z, w + 1]):
      markReached(reached, x, y, z, w + 1)

proc possible(): bool = #2.1
  # Checks if the maze is possible to solve.
  var reached = newTensor[bool](size)
  markReached(reached, Player.pos[X], Player.pos[Y], Player.pos[Z], Player.pos[W])
  return reached[Goal.pos[X], Goal.pos[Y], Goal.pos[Z], Goal.pos[W]]

proc generateMaze() = #2
  for x in 0 ..< size[X]:
    for y in 0 ..< size[Y]:
      for z in 0 ..< size[Z]:
        for w in 0 ..< size[W]:
          if rand(1.0) < SpaceChance:
            maze[x, y, z, w] = Space
          else:
            maze[x, y, z, w] = Wall
  
  Player.pos = randomPos()
  Goal.pos = randomPos()

  maze.atIndex(Player.pos) = Space
  maze.atIndex(Goal.pos) = Space

  if not possible():
    generateMaze()

proc mazeInit() =
  generateMaze()
  drawBoard()

proc checkWin() =
  if Player.pos == Goal.pos:
    mazeInit()

proc mouseClicked(dt: float32) =
  if mousebtn 0:
    let
      (clickX, clickY) = mouse()
      x = clickX div cellScale mod (size[X]+1)
      y = clickY div cellScale mod (size[Y]+1)
      z = clickX div cellScale div (size[X]+1)
      w = clickY div cellScale div (size[Y]+1)
      mousePos: Position = @[x, y, z, w]

    if mousePos.all m => size.all s => (m >= 0) and (m < s):
      let diffVector = zip(mousePos, Player.pos).map v => v[0] - v[1]

      if diffVector.map(d => abs d).sum() < 2:
        attemptToMove(diffVector[X..W])
        checkWin() 

proc gameInit() =
  randomize()
  setPalette loadPaletteFromGPL "RGB Gradients.gpl"
  mazeInit()

nico.init("CubixThree", "polycore")
nico.createWindow("polycore", boardWidth(), boardHeight(), 1, false)
nico.run(gameInit, mouseClicked, drawBoard)