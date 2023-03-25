import
  nico,
  math, seqmath,
  algorithm, sets,
  random,
  sugar

proc setstage(stage: int):
  case stage == 0: introText()
  else: return


proc introText() =
  setColor palIndex(255, 255, 255)
  printc("Once there was a duck worm named Duck Worm.",  100, 100)
  printc("He had a friend named Duck Ball.", 100, 112)
  printc("Duck Ball got lost in the forest", 100, 125)
  printc("when they were walking together...", 100, 137)

proc gameInit() =
  echo "Game started!"

proc getInput(dt: float32) =
  return

nico.init("Cubix", "Duck Worm")
nico.createWindow("Duck Worm", 200, 200, 8, false)
nico.run(gameInit, getInput, introText)









































































