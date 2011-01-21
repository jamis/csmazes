###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze.Algorithms.GrowingTree extends Maze.Algorithm
  QUEUE: 0x10

  constructor: (maze, options) ->
    super
    @cells = []
    @state = 0
    @weights = options.input ? { random: 50 }

    @totalWeights = 0
    for key, weight of @weights
      @totalWeights += weight

  inQueue: (x, y) -> @maze.isSet(x, y, @QUEUE)

  enqueue: (x, y) ->
    @maze.carve x, y, @QUEUE
    @cells.push x: x, y: y
    @callback @maze, x, y

  nextCell: ->
    target = @rand.nextInteger(@totalWeights)
    ceil = 0

    for key, weight of @weights
      ceil += weight
      if ceil > target
        return switch key
          when 'random' then @rand.nextInteger(@cells.length)
          when 'newest' then @cells.length - 1
          when 'oldest' then 0
          when 'middle' then Math.floor(@cells.length / 2)
          else throw "invalid weight key `#{key}'"

    throw "[bug] shouldn't get here"
    
  startStep: ->
    @enqueue @rand.nextInteger(@maze.width), @rand.nextInteger(@maze.height)
    @state = 1

  runStep: ->
    index = @nextCell()
    cell = @cells[index]

    for direction in @rand.randomDirections()
      nx = cell.x + Maze.Direction.dx[direction]
      ny = cell.y + Maze.Direction.dy[direction]

      if @maze.isValid(nx, ny) && @maze.isBlank(nx, ny)
        @maze.carve cell.x, cell.y, direction
        @maze.carve nx, ny, Maze.Direction.opposite[direction]
        @enqueue nx, ny
        @callback @maze, cell.x, cell.y
        @callback @maze, nx, ny
        return

    @cells.splice(index, 1)
    @maze.uncarve cell.x, cell.y, @QUEUE
    @callback @maze, cell.x, cell.y
    
  step: ->
    switch @state
      when 0 then @startStep()
      when 1 then @runStep()

    @cells.length > 0
