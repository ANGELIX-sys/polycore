import nico, main


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
    if mousePos == Player.pos: "player"
    elif mousePos == Goal.pos: "goal"
    else:
      try:
        if maze.atIndex(mousePos) == PASSABLE: "space"
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
