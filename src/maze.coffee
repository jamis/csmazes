###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze
  constructor: (@width, @height, algorithm, options) ->
    options ?= {}
    @grid = new Maze.Grid(@width, @height)
    @rand = options.rng || new MersenneTwister(options.seed)
    @isWeave = options.weave

    unless @rand.randomElement?
      @rand.randomElement = (list) -> list[@nextInteger(list.length)]
      @rand.removeRandomElement = (list) ->
        results = list.splice(@nextInteger(list.length), 1)
        if results then results[0]
      @rand.randomizeList = (list) ->
        i = list.length - 1
        while i > 0
          j = @nextInteger(i+1)
          [list[i], list[j]] = [list[j], list[i]]
          i--
        list
      @rand.randomDirections = -> @randomizeList Maze.Direction.List.slice(0)

    @algorithm = new algorithm(this, options)

  onUpdate: (fn) -> @algorithm.onUpdate(fn)
  onEvent: (fn) -> @algorithm.onEvent(fn)

  generate: -> loop
    break unless @step()

  step: -> @algorithm.step()

  isEast: (x, y) -> @grid.isMarked(x, y, Maze.Direction.E)
  isWest: (x, y) -> @grid.isMarked(x, y, Maze.Direction.W)
  isNorth: (x, y) -> @grid.isMarked(x, y, Maze.Direction.N)
  isSouth: (x, y) -> @grid.isMarked(x, y, Maze.Direction.S)
  isUnder: (x, y) -> @grid.isMarked(x, y, Maze.Direction.U)
  isValid: (x, y) -> 0 <= x < @width and 0 <= y < @height
  carve: (x, y, dir) -> @grid.mark(x, y, dir)
  uncarve: (x, y, dir) -> @grid.clear(x, y, dir)
  isSet: (x, y, dir) -> @grid.isMarked(x, y, dir)
  isBlank: (x, y) -> @grid.at(x, y) == 0
  isPerpendicular: (x, y, dir) -> (@grid.at(x, y) & Maze.Direction.Mask) == Maze.Direction.cross[dir]

Maze.Algorithms = {}

class Maze.Algorithm
  constructor: (@maze, options) ->
    options ?= {}
    @updateCallback = (maze, x, y) ->
    @eventCallback = (maze, x, y) ->
    @rand = @maze.rand

  onUpdate: (fn) -> @updateCallback = fn
  onEvent: (fn) -> @eventCallback = fn

  updateAt: (x, y) -> @updateCallback(@maze, parseInt(x), parseInt(y))
  eventAt: (x, y) -> @eventCallback(@maze, parseInt(x), parseInt(y))

  canWeave: (dir, thruX, thruY) ->
    if @maze.isWeave && @maze.isPerpendicular(thruX, thruY, dir)
      nx = thruX + Maze.Direction.dx[dir]
      ny = thruY + Maze.Direction.dy[dir]
      @maze.isValid(nx, ny) && @maze.isBlank(nx, ny)

  performThruWeave: (thruX, thruY) ->
    if @rand.nextBoolean()
      @maze.carve(thruX, thruY, Maze.Direction.U)
    else if @maze.isNorth(thruX, thruY)
      @maze.uncarve(thruX, thruY, Maze.Direction.N|Maze.Direction.S)
      @maze.carve(thruX, thruY, Maze.Direction.E|Maze.Direction.W|Maze.Direction.U)
    else
      @maze.uncarve(thruX, thruY, Maze.Direction.E|Maze.Direction.W)
      @maze.carve(thruX, thruY, Maze.Direction.N|Maze.Direction.S|Maze.Direction.U)

  performWeave: (dir, fromX, fromY, callback) ->
    thruX = fromX + Maze.Direction.dx[dir]
    thruY = fromY + Maze.Direction.dy[dir]
    toX = thruX + Maze.Direction.dx[dir]
    toY = thruY + Maze.Direction.dy[dir]

    @maze.carve(fromX, fromY, dir)
    @maze.carve(toX, toY, Maze.Direction.opposite[dir])

    @performThruWeave(thruX, thruY)

    callback(toX, toY) if callback

    @updateAt fromX, fromY
    @updateAt thruX, thruY
    @updateAt toX, toY

Maze.Direction =
  N: 0x01
  S: 0x02
  E: 0x04
  W: 0x08
  U: 0x10
  Mask: (0x01|0x02|0x04|0x08|0x10)
  List: [1, 2, 4, 8]
  dx: { 1: 0, 2: 0, 4: 1, 8: -1 }
  dy: { 1: -1, 2: 1, 4: 0, 8: 0 }
  opposite: { 1: 2, 2: 1, 4: 8, 8: 4 }
  cross: { 1: 4|8, 2: 4|8, 4: 1|2, 8: 1|2 }

class Maze.Grid
  constructor: (@width, @height) ->
    @data = ((0 for x in [1..@width]) for y in [1..@height])

  at: (x, y) -> @data[y][x]
  mark: (x, y, bits) -> @data[y][x] |= bits
  clear: (x, y, bits) -> @data[y][x] &= ~bits
  isMarked: (x, y, bits) -> (@data[y][x] & bits) == bits
