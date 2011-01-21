###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze.Algorithms.HuntAndKill extends Maze.Algorithm
  IN: 0x10

  constructor: (maze, options) ->
    super
    @state = 0

  isCurrent: (x, y) -> (@x ? x) == x && @y == y
  isWalking: -> @state == 1
  isHunting: -> @state == 2

  callbackRow: (y) ->
    for x in [0...@maze.width]
      @callback @maze, x, y

  startStep: ->
    @x = @rand.nextInteger(@maze.width)
    @y = @rand.nextInteger(@maze.height)
    @maze.carve @x, @y, @IN
    @callback @maze, @x, @y
    @state = 1

  walkStep: ->
    for direction in @rand.randomDirections()
      nx = @x + Maze.Direction.dx[direction]
      ny = @y + Maze.Direction.dy[direction]

      if @maze.isValid(nx, ny) && @maze.isBlank(nx, ny)
        [x, y, @x, @y] = [@x, @y, nx, ny]
        @maze.carve x, y, direction
        @maze.carve nx, ny, Maze.Direction.opposite[direction]
        @callback @maze, x, y
        @callback @maze, nx, ny
        return

    [x, y] = [@x, @y]
    delete @x
    delete @y
    @callback @maze, x, y # remove highlight from current cell
    @y = 0
    @callbackRow 0 # highlight the first row
    @state = 2

  huntStep: ->
    for x in [0...@maze.width]
      if @maze.isBlank(x, @y)
        neighbors = []
        neighbors.push Maze.Direction.N if @y > 0 && !@maze.isBlank(x, @y-1)
        neighbors.push Maze.Direction.W if x > 0 && !@maze.isBlank(x-1, @y)
        neighbors.push Maze.Direction.S if @y+1 < @maze.height && !@maze.isBlank(x, @y+1)
        neighbors.push Maze.Direction.E if x+1 < @maze.width && !@maze.isBlank(x+1, @y)

        direction = @rand.randomElement(neighbors)
        if direction
          @x = x

          nx = @x + Maze.Direction.dx[direction]
          ny = @y + Maze.Direction.dy[direction]

          @maze.carve @x, @y, direction
          @maze.carve nx, ny, Maze.Direction.opposite[direction]

          @state = 1

          # update passages for neighbor
          @callback @maze, nx, ny

          # clear highlight in row (because we set @x) and update passages at @x, @y
          @callbackRow @y

          return

    @y++
    @callbackRow @y-1 # clear highlight for prior row

    if @y >= @maze.height
      @state = 3
      delete @x
      delete @y
    else
      @callbackRow @y # highlight next row

  step: ->
    switch @state
      when 0 then @startStep()
      when 1 then @walkStep()
      when 2 then @huntStep()

    @state != 3
