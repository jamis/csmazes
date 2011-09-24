###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze.Algorithms.HuntAndKill extends Maze.Algorithm
  IN: 0x1000

  constructor: (maze, options) ->
    super
    @state = 0

  isCurrent: (x, y) -> (@x ? x) == x && @y == y
  isWalking: -> @state == 1
  isHunting: -> @state == 2

  callbackRow: (y) ->
    for x in [0...@maze.width]
      @updateAt x, y

  startStep: ->
    @x = @rand.nextInteger(@maze.width)
    @y = @rand.nextInteger(@maze.height)
    @maze.carve @x, @y, @IN
    @updateAt @x, @y
    @state = 1

  walkStep: ->
    for direction in @rand.randomDirections()
      nx = @x + Maze.Direction.dx[direction]
      ny = @y + Maze.Direction.dy[direction]

      if @maze.isValid(nx, ny)
        if @maze.isBlank(nx, ny)
          [x, y, @x, @y] = [@x, @y, nx, ny]
          @maze.carve x, y, direction
          @maze.carve nx, ny, Maze.Direction.opposite[direction]
          @updateAt x, y
          @updateAt nx, ny
          return

        else if @canWeave(direction, nx, ny)
          @performWeave direction, @x, @y, (x, y) =>
            [x, y, @x, @y] = [@x, @y, x, y]
          return

    [x, y] = [@x, @y]
    delete @x
    delete @y
    @updateAt x, y # remove highlight from current cell
    @eventAt x, y
    @y = 0
    @state = 2
    @callbackRow 0 # highlight the first row

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
          @updateAt nx, ny

          # clear highlight in row (because we set @x) and update passages at @x, @y
          @callbackRow @y
          @eventAt nx, ny

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
