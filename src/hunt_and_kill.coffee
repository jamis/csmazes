###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze.HuntAndKill extends Maze
  IN: 0x10

  constructor: (width, height, options) ->
    super
    @state = 0

  isCurrent: (x, y) -> @x == x && @y == y
  isWalking: -> @state == 1
  isHunting: -> @state == 2

  startStep: ->
    @x = @rand.nextInteger(@width)
    @y = @rand.nextInteger(@height)
    @carve @x, @y, @IN
    @callback this, @x, @y
    @state = 1

  walkStep: ->
    for direction in @randomDirections()
      nx = @x + Maze.Direction.dx[direction]
      ny = @y + Maze.Direction.dy[direction]

      if @isValid(nx, ny) && @isBlank(nx, ny)
        [x, y, @x, @y] = [@x, @y, nx, ny]
        @carve x, y, direction
        @carve nx, ny, Maze.Direction.opposite[direction]
        @callback this, x, y
        @callback this, nx, ny
        return

    [x, y] = [@x, @y]
    delete @x
    delete @y
    @callback this, x, y
    @x = 0
    @y = 0
    @callback this, 0, 0
    @state = 2

  huntStep: ->
    if @isBlank(@x, @y)
      neighbors = []
      neighbors.push Maze.Direction.N if @y > 0 && !@isBlank(@x, @y-1)
      neighbors.push Maze.Direction.W if @x > 0 && !@isBlank(@x-1, @y)
      neighbors.push Maze.Direction.S if @y+1 < @height && !@isBlank(@x, @y+1)
      neighbors.push Maze.Direction.E if @x+1 < @width && !@isBlank(@x+1, @y)

      direction = @randomElement(neighbors)
      if direction
        nx = @x + Maze.Direction.dx[direction]
        ny = @y + Maze.Direction.dy[direction]

        @carve @x, @y, direction
        @carve nx, ny, Maze.Direction.opposite[direction]

        @state = 1
        @callback this, nx, ny
        @callback this, @x, @y
        return

    [x, y, @x, @y] = [@x, @y, @x+1, @y]

    if @x >= @width
      @x = 0
      @y++

    if @y >= @height
      @state = 3
      delete @x
      delete @y
    else
      @callback this, @x, @y

    @callback this, x, y

  step: ->
    switch @state
      when 0 then @startStep()
      when 1 then @walkStep()
      when 2 then @huntStep()

    @state != 3
