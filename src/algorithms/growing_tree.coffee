###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze.Algorithms.GrowingTree extends Maze.Algorithm
  QUEUE: 0x1000

  constructor: (maze, options) ->
    super
    @cells = []
    @state = 0
    @script = new Maze.Algorithms.GrowingTree.Script(options.input ? "random", @rand)

  inQueue: (x, y) -> @maze.isSet(x, y, @QUEUE)

  enqueue: (x, y) ->
    @maze.carve x, y, @QUEUE
    @cells.push x: x, y: y

  nextCell: -> @script.nextIndex(@cells.length)
    
  startStep: ->
    [x, y] = [@rand.nextInteger(@maze.width), @rand.nextInteger(@maze.height)]
    @enqueue x, y
    @updateAt x, y
    @state = 1

  runStep: ->
    index = @nextCell()
    cell = @cells[index]

    for direction in @rand.randomDirections()
      nx = cell.x + Maze.Direction.dx[direction]
      ny = cell.y + Maze.Direction.dy[direction]

      if @maze.isValid(nx, ny)
        if @maze.isBlank(nx, ny)
          @maze.carve cell.x, cell.y, direction
          @maze.carve nx, ny, Maze.Direction.opposite[direction]
          @enqueue nx, ny
          @updateAt cell.x, cell.y
          @updateAt nx, ny
          return

        else if @canWeave(direction, nx, ny)
          @performWeave(direction, cell.x, cell.y, (toX, toY) => @enqueue(toX, toY))
          return

    @cells.splice(index, 1)
    @maze.uncarve cell.x, cell.y, @QUEUE
    @updateAt cell.x, cell.y
    
  step: ->
    switch @state
      when 0 then @startStep()
      when 1 then @runStep()

    @cells.length > 0

class Maze.Algorithms.GrowingTree.Script
  constructor: (input, rand) ->
    @rand = rand
    @commands = for command in input.split(/;|\r?\n/)
      totalWeight = 0
      parts = for part in command.split(/,/)
        [name, weight] = part.split(/:/)
        totalWeight += parseInt(weight ? 100)
        { name: name.replace(/\s/, ""), weight: totalWeight }
      { total: totalWeight, parts: parts }
    @current = 0

  nextIndex: (ceil) ->
    command = @commands[@current]
    @current = (@current + 1) % @commands.length

    target = @rand.nextInteger(command.total)
    for part in command.parts
      if target < part.weight
        return switch part.name
          when 'random' then @rand.nextInteger(ceil)
          when 'newest' then ceil - 1
          when 'middle' then Math.floor(ceil / 2)
          when 'oldest' then 0
          else throw "invalid weight key `#{part.name}'"
