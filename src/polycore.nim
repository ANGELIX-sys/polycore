import colors
import options
import nico
import sequtils
import seqmath
import arraymancer as arrman
import arraymancer/tensor/private/p_accessors

# Types
type
  # A position in the maze.
  Position* = seq[int]

  # Path made up of positions in the maze.
  Path* = seq[Position]

type
  # Sometimes, Cells contain CellObjs; this can be a 
  CellObj* = object
    solid*: bool
    color*: Color
    containingCell*: ref Option[Cell] # The cell that contains this CellObj
    usePlayerInput*: bool # Use the player's input to control this object.
    inv*: ref seq[CellObj] # The inventory of the player.
    bumpedInto*: proc(obj: var CellObj, bumper: var CellObj): void
    hostile*: bool # Can this object hurt the player?
    moveset*: proc(): seq[seq[int]] # A proc that outputs a certain path to follow; basically the CellObj's AI.

  # Every Maze is made up of Cells.
  Cell* = object
    pos*: seq[int]
    cellObjs*: ref seq[CellObj]
    maze*: ref Option[Maze]

  # The maze itself has a tensor made of cells.
  Maze* = object
    cells*: Tensor[Cell]
    size*: seq[int]
    debugMode*: bool
    playerControlledObjs*: ref seq[CellObj]
    target*: ref Option[CellObj]


  #[
    # A win condition. Once it's fully implemented it should be tied to the Maze object.

    # if Player.position == Target.position: condition = true
    # if Player on Target: condition = true
    # if
    type
      WinCondition = bool
    var winConditions = seq[WinCondition]
    ]#


proc attemptToMove(obj: var CellObj, vect: seq[int]) =
  if (obj.containingCell[].isNone()):
    return
  var moveResult: Position = eAdd(obj.containingCell[].get().pos, vect)
  var maze = obj.containingCell[].get().maze[].get()
  for (s, r) in zip(maze.size, moveResult):
    if maze.debugMode: echo (width: s, position: r)
    if r notin 0 ..< s:
      if maze.debugMode: echo "Out of bounds: width - pos = ", s - abs(r), "! Thats no good..."
      return
  
  obj.containingCell[].get().cellObjs[].delete(obj.containingCell[].get().cellObjs[].find(obj))
  obj.containingCell[] = some(maze.cells.atIndex(moveResult))
  maze.cells.atIndex(moveResult).cellObjs[].add(obj)


  # if maze.atIndex(moveResult).pushable:
    # attemptToMove(maze.atIndex(moveResult), vect)

# Object bumpedInto procs
proc pushObj(obj: var CellObj, bumper: var CellObj): void =
  if (obj.containingCell[].isNone()) or (bumper.containingCell[].isNone()):
    return
  var bumperPos = bumper.containingCell[].get().pos
  var objPos = obj.containingCell[].get().pos
  
  attemptToMove(obj, eSub(objPos, bumperPos))
  return

# In-game objects
proc makePlayer*(): CellObj =
  var container = Option[Cell].new()
  container[] = none(Cell)
  return CellObj(color: Color(0x0000FF), containingCell: container, usePlayerInput: true)
  
proc makeTarget*(): CellObj =
  var container = Option[Cell].new()
  container[] = none(Cell)
  return CellObj(color: Color(0x00FF00), containingCell: container)
  
proc makeCrate*(): CellObj =
  var container = Option[Cell].new()
  container[] = none(Cell)
  return CellObj(color: Color(0xAAAA00), containingCell: container, bumpedInto: pushObj)

proc makeSpace*(): CellObj = 
  var container = Option[Cell].new()
  container[] = none(Cell)
  return CellObj(color: Color(0xFFFFFF), containingCell: container, solid: false)

proc makeWall*(): CellObj = 
  var container = Option[Cell].new()
  container[] = none(Cell)
  return CellObj(color: Color(0x000000), containingCell: container, solid: true)

  # If Cell.hostile = true, do Cell.damage upon collision with player.
  # May add a way to Pacify Mobs so that attacks do no damage.
  # mook* = Cell(pos: @[0], obj: cMob, color: Color(0xFF0000), hp: 1, def: 0, spd: 1, hostile: true, dmg: 1)
  # bird* = Cell(pos: @[0], obj: cMob, color: Color(0x00FF77), layer: 1, hp: 2, def: 0, dmg: 2, spd: 2)


# Cross-module compatibility
template setColor*(color: Color) =
  let (r, g, b) = extractRGB(color)
  setColor palIndex(r.uint8, g.uint8, b.uint8)

# Procedures

proc `$`*(c: Cell): string =
  return # c, " at position ", $c.pos

proc `==`*(a, b: Cell): bool =
  return

proc seqsToIndex*(mn, mx: seq[int], inclusive: bool = false): seq[Slice] = 
  return