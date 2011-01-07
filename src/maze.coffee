###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze
  constructor: (@width, @height, options) ->
    options ?= {}
    @callback = options.callback || (maze, x, y) ->
    @grid = new Maze.Grid(@width, @height)
    @rand = options.rng || new MersenneTwister(options.seed)

  randomBoolean: -> @rand.nextBoolean()

  randomElement: (list) -> list[@rand.nextInteger(list.length)]

  removeRandomElement: (list) ->
    results = list.splice(@rand.nextInteger(list.length), 1)
    if results then results[0]

  randomizeList: (list) ->
    i = list.length - 1
    while i > 0
      j = @rand.nextInteger(i+1)
      [list[i], list[j]] = [list[j], list[i]]
      i--
    list

  randomDirections: -> @randomizeList [1, 2, 4, 8]

  generate: -> loop
    break unless @step()

  isEast: (x, y) -> @grid.isMarked(x, y, Maze.Direction.E)
  isWest: (x, y) -> @grid.isMarked(x, y, Maze.Direction.W)
  isNorth: (x, y) -> @grid.isMarked(x, y, Maze.Direction.N)
  isSouth: (x, y) -> @grid.isMarked(x, y, Maze.Direction.S)
  isValid: (x, y) -> 0 <= x < @width and 0 <= y < @height
  carve: (x, y, dir) -> @grid.mark(x, y, dir)
  uncarve: (x, y, dir) -> @grid.clear(x, y, dir)
  isSet: (x, y, dir) -> @grid.isMarked(x, y, dir)
  isBlank: (x, y, dir) -> @grid.at(x, y, dir) == 0

Maze.Direction =
  N: 1
  S: 2
  E: 4
  W: 8
  dx: { 1: 0, 2: 0, 4: 1, 8: -1 }
  dy: { 1: -1, 2: 1, 4: 0, 8: 0 }
  opposite: { 1: 2, 2: 1, 4: 8, 8: 4 }

class Maze.Grid
  constructor: (@width, @height) ->
    @data = ((0 for x in [1..@width]) for y in [1..@height])

  at: (x, y) -> @data[y][x]
  mark: (x, y, bits) -> @data[y][x] |= bits
  clear: (x, y, bits) -> @data[y][x] &= ~bits
  isMarked: (x, y, bits) -> (@data[y][x] & bits) == bits
