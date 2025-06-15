import random

include polycore

using
  pos, vect: Position
  obj: var Cell

# import debugs


nico.init("Cubix", "polycore")
setPalette loadPaletteFromGPL "RGB Gradients.gpl"
randomize()


var
  dims: int
  maze: Maze
  size: seq[int]


var
  cellScale: int
  offset: float

proc boardWidth(a1 = 0, a2 = 2): int =
  result = (size[a1] * size[a2] + size[a2] - 1) * cellScale

proc boardHeight(a1 = 1, a2 = 3): int =
  result = (size[a1] * size[a2] + size[a2] - 1) * cellScale

proc toCoords(pos): tuple[x: int, y: int] =
  proc coordsHalf(half: int): int =
    var
      i = half
      j = 2
      k = 1
      m = 0
    result = pos[i]
    if dims <= 2:
      result *= cellScale
      return
    else:
      while i < dims-2:
        i += 2
        j = 2 # 
        k = 1 # Added to result
        m = 0 # Barrier between dimensions, increases by one per pair of dimensions
        while j < dims:
          if j <= i:
            k *= size[i-j] + m
            k -= m
          j += 2
          m += 1
        result += (k + i div 2) * pos[i]
    result *= cellScale
  
  (x: coordsHalf(0),
   y: coordsHalf(1))
  # What I thought it was: d0 + d1 * (size[d0] + 1) + d2 * (size[d1] + 2)...
  # What it actually is:
  # d0 + d2 * (size[d1] + 1) + d4 * ((size[d1] + 1) * (size[d3] + 2))???


proc draw(obj: Cell, pos) =
  let (x, y) = pos.toCoords
  setColor obj.color
  boxfill(x, y, cellScale, cellScale)

proc draw(obj: CellObj, pos) =
  let (x, y) = pos.toCoords
  setColor obj.color
  boxfill(x, y, cellScale, cellScale)

proc drawBoard() =
  setColor 0
  boxfill(0, 0, screenWidth, screenHeight)
  
  for pos, cell in maze.cells:
    draw cell, pos
    if (cell.cellObjs[].len > 0):
      draw cell.cellObjs[0], pos

#[ proc toPos(cx, cy: int): Position = # Ditch moues controls
  var
    val: int
    doDiv: seq[bool] = newSeq[bool](dims div 2)

  for i in 0..<dims: # This is going to be a doozy to explain
    if i mod 2 == 0:
      if debugs and keyp(K_L): dump cx div cellScale - offset
      val = cx div cellScale - offset
    else:
      if debugs and keyp(K_L): dump cy div cellScale - offset
      val = cy div cellScale - offset
    
    if dims > 2:
      for j in 0..<(dims div 2):
        if doDiv[j]:
          if debugs and keyp(K_L):
            dump size[i] + j
            dump val div (size[i] + j)

          val = val div (size[i] + j)
        else:
          if debugs and keyp(K_L):
            dump size[i] + j
            dump val mod (size[i] + j)

          val = val mod (size[i] + j)
          if i mod 2 == 1:
            if debugs and keyp(K_L): echo "doDiv = true"
            doDiv[j] = true
    
    result &= val
  if debugs and keyp(K_L): echo result

proc toPos(coords: (int, int)): Position = toPos(coords[0], coords[1]) ]#


proc moveBy(obj: var CellObj, dim: Natural, amt: int) =
  var vector = newSeq[int](dims)
  vector[dim-1] = amt
  if obj.containingCell[].get().maze[].get().debugMode: echo eAdd(vector, obj.containingCell[].get().pos), " - ", vector
  obj.attemptToMove vector

#[ proc mouseClicked() =
  # The actual position of the mouse
  let clickPos = mouse().toPos()
  # The relative position of the mouse to the player
  let moveVect = eSub(clickPos, player.pos)
  if debugs: echo clickPos, " - ", moveVect

  # The player can only move one space at a time, no diagonals.
  # This checks if the vector only contains a single 1 of either sign.
  # NOTE: I might add a Power that lets the player move further,
  # so this value may need to become a property tied to Mobs/Players.
  if sum(abs moveVect) <= 1:
    player.attemptToMove moveVect ]#

var shiftVal = 1
proc arrowAction() =
  # Dimension shifting
  # min = 1
  # max = Dims
  if key(K_LSHIFT):
    if keyp(K_RIGHT):
      shiftVal += 2
      if shiftVal > dims:
        shiftVal = 1
    elif keyp(K_LEFT):
      shiftVal -= 2
      if shiftVal < 1:
        shiftVal = dims - 1
    # View shifting
  else:  
  # Movement
    for cellObj in maze.playerControlledObjs[].mitems:
      if K_RIGHT.keypr 10: cellObj.moveBy shiftVal, 1
      elif K_LEFT.keypr 10: cellObj.moveBy shiftVal, -1

      if shiftVal != dims:
        if K_DOWN.keypr 10: cellObj.moveBy (shiftVal + 1), 1
        elif K_UP.keypr 10: cellObj.moveBy (shiftVal + 1), -1


proc checkProperScale*() =
  echo "Board size: ", (boardWidth(), boardHeight()), "; ",
       "Screen size: ", (screenWidth, screenHeight)

  echo "Maze scale: ", cellScale

  let highestPos = size.eSub(1)

  echo "Maze bottom right position: ", highestPos
  echo "Maze shape: ", size.eSub(1)

  let (sizeCoords, highestCoords) = (size.eSub(1).toCoords(),
      highestPos.toCoords())
  echo "As coordinates: ", (shape: sizeCoords, corner: highestCoords)
  if sizeCoords != highestCoords:
    echo "Not the right amount!"
    echo "Difference: ",
      (sizeCoords.x - highestCoords.x,
       sizeCoords.y - highestCoords.y)


proc mazeInit() =
  shiftVal = 1
  cellScale = 16
  offset = 0

  size = @[4, 4, 4, 4]
  dims = size.len
  maze.size = size
  maze.cells = newTensor[Cell](size) # Just a bit awkward because newTensorWith sucks when "shape" is varargs.
  new (maze.target)
  new(maze.playerControlledObjs)
  for (pos, _) in maze.cells.pairs:
    var newSpace = makeSpace()
    maze.cells.atIndexMut(pos, newSpace)
    maze.cells.atIndex(pos).pos = pos
    maze.cells.atIndex(pos).maze[] = some(maze)
  var player = makePlayer()
  maze.cells.atIndex(0, 0, 0, 0).cellObjs[].add(player)
  player.containingCell[] = some(maze.cells.atIndex(0, 0, 0, 0))
  maze.playerControlledObjs[].add(player)

  var target = makeTarget()
  maze.cells.atIndex(3, 3, 3, 3).cellObjs[].add(target)
  target.containingCell[] = some(maze.cells.atIndex(3, 3, 3, 3))
  maze.target[] = some(target)

  nico.setTargetSize(boardWidth(), boardHeight())
  nico.setScreenSize(boardWidth(), boardHeight())
  drawBoard()

proc getInput(dt: float32) =
  if maze.debugMode:
    # if keyp(K_C): getAllCoords()
    if keyp(K_F): echo "Current movement plane: ", shiftVal

    elif keyp(K_S): checkProperScale()

    # if keyp(K_P) and mousebtnp(0): checkRightPositions()

    if keyp(K_D): maze.debugMode = false

  elif keyp(K_D): maze.debugMode = true
  cellScale += mousewheel()
  if mousewheel() == 1:
    offset /= 2
  elif mousewheel() == -1:
    offset *= 2
  # if mousebtn(0): mouseClicked()
  arrowAction()
  for (_, obj) in maze.playerControlledObjs[].pairs:
    var target = maze.target[].get()
    if keyp(K_A): echo "Player at ", obj.containingCell[].get().pos, ", Goal at ", target.containingCell[].get().pos
    if target.containingCell[].get().pos == obj.containingCell[].get().pos or keyp(K_R): mazeInit()


nico.createWindow("polycore", 128, 128)
nico.run(mazeInit, getInput, drawBoard)
