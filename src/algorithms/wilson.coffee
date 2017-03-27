###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze.Algorithms.Wilson extends Maze.Algorithm
  IN: 0x1000

  constructor: (maze, options) ->
    super
    @state = 0
    @remaining = @maze.width * @maze.height
    @visits = {}

  isCurrent: (x, y) -> @x == x && @y == y
  isVisited: (x, y) -> @visits["#{x}:#{y}"]?

  addVisit: (x, y, dir) -> @visits["#{x}:#{y}"] = dir ? 0
  exitTaken: (x, y) -> @visits["#{x}:#{y}"]

  startStep: ->
    x = @rand.nextInteger(@maze.width)
    y = @rand.nextInteger(@maze.height)
    @maze.carve x, y, @IN
    @updateAt x, y
    @remaining--
    @state = 1

  startWalkStep: ->
    @visits = {}

    loop
      @x = @rand.nextInteger(@maze.width)
      @y = @rand.nextInteger(@maze.height)
      if @maze.isBlank(@x, @y)
        @eventAt @x, @y
        @state = 2
        @start = x: @x, y: @y
        @addVisit @x, @y
        @updateAt @x, @y
        break

  walkStep: ->
    for direction in @rand.randomDirections()
      nx = @x + Maze.Direction.dx[direction]
      ny = @y + Maze.Direction.dy[direction]

      if @maze.isValid(nx, ny)
        [x, y, @x, @y] = [@x, @y, nx, ny]

        if @isVisited(nx, ny)
          @eraseLoopFrom(nx, ny)
        else
          @addVisit x, y, direction

        @updateAt x, y
        @updateAt nx, ny

        unless @maze.isBlank(nx, ny)
          @x = @start.x
          @y = @start.y
          @state = 3
          @eventAt @x, @y

        break

  resetVisits: ->
    for key, dir of @visits
      [x, y] = key.split(":")
      delete @visits[key]
      @updateAt x, y

  runStep: ->
    if @remaining > 0
      dir = @exitTaken(@x, @y)
      nx = @x + Maze.Direction.dx[dir]
      ny = @y + Maze.Direction.dy[dir]

      unless @maze.isBlank(nx, ny)
        @resetVisits()
        @state = 1

      @maze.carve @x, @y, dir
      @maze.carve nx, ny, Maze.Direction.opposite[dir]

      [x, y, @x, @y] = [@x, @y, nx, ny]

      if @state == 1
        delete @x
        delete @y

      @updateAt x, y
      @updateAt nx, ny

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

  eraseLoopFrom: (x, y) ->
    while true
      dir = @exitTaken(x, y)
      break unless dir

      nx = x + Maze.Direction.dx[dir]
      ny = y + Maze.Direction.dy[dir]

      key = "#{x}:#{y}"
      delete @visits[key]
      @updateAt x, y

      [x, y] = [nx, ny]
