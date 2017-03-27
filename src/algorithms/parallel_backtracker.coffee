###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze.Algorithms.ParallelBacktracker extends Maze.Algorithm
  IN:    0x1000
  STACK: 0x2000

  START: 1
  RUN:   2
  DONE:  3

  constructor: (maze, options) ->
    super

    @cells = []
    @sets = {}

    for x in [0...maze.height]
      for y in [0...maze.width]
        name = "c#{x}r#{y}"

        north = "c#{x}r#{y-1}"
        south = "c#{x}r#{y+1}"
        east  = "c#{x+1}r#{y}"
        west  = "c#{x-1}r#{y}"

        cell = { x: x, y: y, name: name, north: north, south: south, west: west, east: east, dirs: @rand.randomDirections() }

        @cells.push cell
        @cells[name] = cell

    @state = @START
    @stacks = ([] for i in [1..(options.input ? 2)])

  step: ->
    switch @state
      when @START then @startStep()
      when @RUN   then @runStep()

    @state != @DONE

  startStep: ->
    indexes = @rand.randomizeList([0...@cells.length])

    for i in [0...@stacks.length]
      cell = @cells[indexes[i]]
      @maze.carve cell.x, cell.y, @IN | @STACK
      @updateAt cell.x, cell.y
      cell.set = "s#{i}"
      @stacks[i] = [ cell ]
      @sets[cell.set] = [ cell ]

    @state = @RUN

  cellAt: (x, y) -> @cells["c#{x}r#{y}"]

  runStep: ->
    activeStacks = 0

    for i in [0...@stacks.length]
      stack = @stacks[i]
      continue if stack.length == 0

      activeStacks += 1

      loop
        current = stack[stack.length - 1]
        dir = current.dirs.pop()

        nx = current.x + Maze.Direction.dx[dir]
        ny = current.y + Maze.Direction.dy[dir]

        if @maze.isValid(nx, ny)
          neighbor = @cellAt(nx, ny)
          if neighbor? && current.set != neighbor.set
            stack.push neighbor
            @maze.carve current.x, current.y, dir
            @maze.carve neighbor.x, neighbor.y, Maze.Direction.opposite[dir] | @STACK

            @updateAt current.x, current.y

            oldSet = neighbor.set
            @sets[oldSet] ?= [ neighbor ]
            for n in @sets[oldSet]
              n.set = current.set
              @sets[current.set].push n
              @updateAt n.x, n.y

            delete @sets[oldSet]
            break

        if current.dirs.length == 0
          @maze.uncarve current.x, current.y, @STACK
          @updateAt current.x, current.y
          stack.pop()
          break

    if activeStacks == 0
      @state = @DONE

      for cell in @cells
        cell.set = "final"
        @updateAt cell.x, cell.y

  isStack: (x, y) -> @maze.isSet(x, y, @STACK)
