###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze.Algorithms.Wilson extends Maze
  IN: 0x10

  constructor: (width, height, options) ->
    super
    @state = 0
    @remaining = @width * @height
    @visits = {}

  isCurrent: (x, y) -> @x == x && @y == y
  isVisited: (x, y) -> @visits["#{x}:#{y}"]?

  addVisit: (x, y, dir) -> @visits["#{x}:#{y}"] = dir ? 0
  exitTaken: (x, y) -> @visits["#{x}:#{y}"]

  startStep: ->
    x = @rand.nextInteger(@width)
    y = @rand.nextInteger(@height)
    @carve x, y, @IN
    @callback this, x, y
    @remaining--
    @state = 1

  startWalkStep: ->
    @visits = {}

    loop
      @x = @rand.nextInteger(@width)
      @y = @rand.nextInteger(@height)
      if @isBlank(@x, @y)
        @state = 2
        @start = x: @x, y: @y
        @addVisit @x, @y
        @callback this, @x, @y
        break

  walkStep: ->
    for direction in @randomDirections()
      nx = @x + Maze.Direction.dx[direction]
      ny = @y + Maze.Direction.dy[direction]

      if @isValid(nx, ny)
        [x, y, @x, @y] = [@x, @y, nx, ny]
        @addVisit x, y, direction
        @callback this, x, y
        @callback this, nx, ny

        unless @isBlank(nx, ny)
          @x = @start.x
          @y = @start.y
          @state = 3

        break

  resetVisits: ->
    for key, dir of @visits
      [x, y] = key.split(":")
      delete @visits[key]
      @callback this, x, y

  runStep: ->
    if @remaining > 0
      dir = @exitTaken(@x, @y)
      nx = @x + Maze.Direction.dx[dir]
      ny = @y + Maze.Direction.dy[dir]

      unless @isBlank(nx, ny)
        @resetVisits()
        @state = 1

      @carve @x, @y, dir
      @carve nx, ny, Maze.Direction.opposite[dir]

      [x, y, @x, @y] = [@x, @y, nx, ny]

      if @state == 1
        delete @x
        delete @y

      @callback this, x, y
      @callback this, nx, ny

      @remaining--

    return @remaining > 0

  step: ->
    if @remaining > 0
      switch @state
        when 0 then @startStep()
        when 1 then @startWalkStep()
        when 2 then @walkStep()
        when 3 then @runStep()

    return @remaining > 0
