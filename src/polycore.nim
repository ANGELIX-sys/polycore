import colors
import nico
import arraymancer


# Types
type
  # A position in the maze.
  Position* = seq[int]

  # Path made up of positions in the maze.
  Path* = seq[Position]

type
  # Different cell types.
  CellObj* = enum
    cPlayer,
    cMob,
    cBlock

  # Every Maze is made up of Cells.
  Cell* = object
    color*: Color
    pos*: seq[int]
    layer*, layerHeight*: int # Yeah, this maze may have an extra dimension. Oh well. layer determines collision, player = 1, space = 0, bird = 2, water = -1... layerHeight determines how many layers "tall" a cell is. 
    hostile*: bool # If false, dmg is nullified.
    hp*, dmg*, def*, spd*: int # Stats. hp-dmg+def for combat, movement speed in squares per turn is spd.
    moveset*: proc(): seq[seq[int]] # If a series of conditions is fulfilled, output a certain path to follow.

    case obj: CellObj
      of cPlayer:
        inv*: seq[Cell] # The inventory of the player.
        mirror*: seq[int] # Flip movement along the desired axis if non-zero
        rotAxis*: int # Rotate movement 90 deg. along the desired axis if non-zero
      of cMob:
        drops*: seq[Cell] # Stuff that drops when the mob is killed.
        mimic*: bool # Mimic the main player character movement (non-rotated/flipped) Good for something like an "evil player" that kills other players.
      of cBlock:
        pushable*: bool # Can this be pushed?
        isItem*: bool # Is this able to be picked up by a player?

  # The maze itself is a tensor made of cells.
  Maze* = Tensor[Cell]


  #[
    # A win condition. Once it's fully implemented it should be tied to the Maze object.

    # if Player.position == Target.position: condition = true
    # if Player on Target: condition = true
    # if
    type
      WinCondition = bool
    var winConditions = seq[WinCondition]
    ]#


# In-game objects

var
  player* = Cell(pos: @[0], obj: cPlayer, color: Color(0x0000FF))
  target* = Cell(pos: @[0], obj: cBlock, color: Color(0x00FF00))
  wall* = Cell(pos: @[0], obj: cBlock, color: Color(0x000000))
  space* = Cell(pos: @[0], obj: cBlock, color: Color(0xFFFFFF))
  crate* = Cell(pos: @[0], obj: cBlock, color: Color(0xAAAA00), pushable: true)
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