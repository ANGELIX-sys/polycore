import sequtils
import seqmath
import math
import sugar
import arraymancer as arrman
import arraymancer/tensor/private/p_accessors
import polycore


type World = seq[array[2, seq[int]]]


const poly*: World = @[ # Goal: 50 Levels
  # Polycore, world 1. Introduction to multidimensional mazes.
  [
    @[6, 6], # Shape
    @[ # Layout
      2,  1,  0,  0,  0,  1,
      0,  1,  0,  1,  0,  1,
      0,  1,  0,  1,  0,  1,
      0,  1,  0,  1,  0,  1,
      0,  1,  0,  1,  0,  1,
      0,  0,  0,  1,  0,  3
    ]
  ]
]