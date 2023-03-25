import math

var
  x = 65
  y = 5

proc notDiv(x, y: int): int =
  return (y / x).int + y

echo x.notDiv y