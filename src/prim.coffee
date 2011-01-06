###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze.Prim extends Maze
  IN:       0x10
  FRONTIER: 0x20

  START:    1
  EXPAND:   2
  DONE:     3

  constructor: (width, height, options) ->
    super(width, height, options)
    @frontierCells = []
    @state = @START

  isOutside: (x, y) -> @isValid(x, y) && @isBlank(x, y)
  isInside: (x, y) -> @isValid(x, y) && @isSet(x, y, @IN)
  isFrontier: (x, y) -> @isValid(x, y) && @isSet(x, y, @FRONTIER)

  addFrontier: (x, y) ->
    if @isOutside(x, y)
      @frontierCells.push {x: x, y: y}
      @carve x, y, @FRONTIER
      @callback this, x, y

  markCell: (x, y) ->
    @carve x, y, @IN
    @uncarve x, y, @FRONTIER
    @callback this, x, y

    @addFrontier x-1, y
    @addFrontier x+1, y
    @addFrontier x, y-1
    @addFrontier x, y+1

  findNeighborsOf: (x, y) ->
    neighbors = []

    neighbors.push(Maze.Direction.W) if @isInside(x-1, y)
    neighbors.push(Maze.Direction.E) if @isInside(x+1, y)
    neighbors.push(Maze.Direction.N) if @isInside(x, y-1)
    neighbors.push(Maze.Direction.S) if @isInside(x, y+1)

    neighbors

  startStep: () ->
    @markCell @rand.nextInteger(@width), @rand.nextInteger(@height)
    @state = @EXPAND

  expandStep: () ->
    cell = @removeRandomElement(@frontierCells)
    direction = @randomElement(@findNeighborsOf(cell.x, cell.y))
    nx = cell.x + Maze.Direction.dx[direction]
    ny = cell.y + Maze.Direction.dy[direction]

    @carve nx, ny, Maze.Direction.opposite[direction]
    @callback this, nx, ny

    @carve cell.x, cell.y, direction
    @markCell cell.x, cell.y

    @state = @DONE if @frontierCells.length == 0

  step: () ->
    switch @state
      when @START  then @startStep()
      when @EXPAND then @expandStep()

    @state != @DONE
