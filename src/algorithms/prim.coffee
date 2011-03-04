###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze.Algorithms.Prim extends Maze.Algorithm
  IN:       0x1000
  FRONTIER: 0x2000

  START:    1
  EXPAND:   2
  DONE:     3

  constructor: (maze, options) ->
    super
    @frontierCells = []
    @state = @START

  isOutside: (x, y) -> @maze.isValid(x, y) && @maze.isBlank(x, y)
  isInside: (x, y) -> @maze.isValid(x, y) && @maze.isSet(x, y, @IN)
  isFrontier: (x, y) -> @maze.isValid(x, y) && @maze.isSet(x, y, @FRONTIER)

  addFrontier: (x, y) ->
    if @isOutside(x, y)
      @frontierCells.push x: x, y: y
      @maze.carve x, y, @FRONTIER
      @updateAt x, y

  markCell: (x, y) ->
    @maze.carve x, y, @IN
    @maze.uncarve x, y, @FRONTIER
    @updateAt x, y

    @addFrontier x-1, y
    @addFrontier x+1, y
    @addFrontier x, y-1
    @addFrontier x, y+1

  findNeighborsOf: (x, y) ->
    neighbors = []

    neighbors.push Maze.Direction.W if @isInside(x-1, y)
    neighbors.push Maze.Direction.E if @isInside(x+1, y)
    neighbors.push Maze.Direction.N if @isInside(x, y-1)
    neighbors.push Maze.Direction.S if @isInside(x, y+1)

    neighbors

  startStep: ->
    @markCell @rand.nextInteger(@maze.width), @rand.nextInteger(@maze.height)
    @state = @EXPAND

  expandStep: ->
    cell = @rand.removeRandomElement(@frontierCells)
    direction = @rand.randomElement(@findNeighborsOf(cell.x, cell.y))
    nx = cell.x + Maze.Direction.dx[direction]
    ny = cell.y + Maze.Direction.dy[direction]

    if @maze.isWeave && @maze.isPerpendicular(nx, ny, direction)
      nx2 = nx + Maze.Direction.dx[direction]
      ny2 = ny + Maze.Direction.dy[direction]
      if @isInside(nx2, ny2)
        @performThruWeave nx, ny
        @updateAt nx, ny
        [nx, ny] = [nx2, ny2]

    @maze.carve nx, ny, Maze.Direction.opposite[direction]
    @updateAt nx, ny

    @maze.carve cell.x, cell.y, direction
    @markCell cell.x, cell.y

    @state = @DONE if @frontierCells.length == 0

  step: ->
    switch @state
      when @START  then @startStep()
      when @EXPAND then @expandStep()

    @state != @DONE
