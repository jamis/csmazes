###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze.Algorithms.Kruskal extends Maze.Algorithm
  WEAVE: 1
  JOIN:  2

  constructor: (maze, options) ->
    super

    @sets = []
    @edges = []

    for y in [0...@maze.height]
      @sets.push([])
      for x in [0...@maze.width]
        @sets[y].push new Maze.Algorithms.Kruskal.Tree()
        @edges.push(x: x, y: y, direction: Maze.Direction.N) if y > 0
        @edges.push(x: x, y: y, direction: Maze.Direction.W) if x > 0

    @rand.randomizeList(@edges)

    @weaveMode = options.weaveMode ? "onePhase"
    @weaveMode = @weaveMode() if typeof @weaveMode == "function"

    @weaveDensity = options.weaveDensity ? 80
    @weaveDensity = @weaveDensity() if typeof @weaveDensity == "function"

    @state = if @maze.isWeave? && @weaveMode == "twoPhase" then @WEAVE else @JOIN

  connect: (x1, y1, x2, y2, direction) ->
    @sets[y1][x1].connect @sets[y2][x2]

    @maze.carve x1, y1, direction
    @updateAt x1, y1

    @maze.carve x2, y2, Maze.Direction.opposite[direction]
    @updateAt x2, y2

  weaveStep: ->
    if !@x?
      @y = 1
      @x = 1

    while @state == @WEAVE
      if @maze.isBlank(@x, @y) && @rand.nextInteger(100) < @weaveDensity
        [nx, ny] = [@x, @y-1]
        [wx, wy] = [@x-1, @y]
        [ex, ey] = [@x+1, @y]
        [sx, sy] = [@x, @y+1]

        safe = !@sets[ny][nx].isConnectedTo(@sets[sy][sx]) &&
          !@sets[wy][wx].isConnectedTo(@sets[ey][ex])

        if safe
          @sets[ny][nx].connect @sets[sy][sx]
          @sets[wy][wx].connect @sets[ey][ex]

          if @rand.nextBoolean()
            @maze.carve @x, @y, Maze.Direction.E|Maze.Direction.W|Maze.Direction.U
          else
            @maze.carve @x, @y, Maze.Direction.N|Maze.Direction.S|Maze.Direction.U

          @maze.carve nx, ny, Maze.Direction.S
          @maze.carve wx, wy, Maze.Direction.E
          @maze.carve ex, ey, Maze.Direction.W
          @maze.carve sx, sy, Maze.Direction.N

          @updateAt @x, @y
          @updateAt nx, ny
          @updateAt wx, wy
          @updateAt ex, ey
          @updateAt sx, sy

          newEdges = []
          for edge in @edges
            continue if (edge.x == @x && edge.y == @y) ||
              (edge.x == ex && edge.y == ey && edge.direction == Maze.Direction.W) ||
              (edge.x == sx && edge.y == sy && edge.direction == Maze.Direction.N)
            newEdges.push(edge)
          @edges = newEdges

          break

      @x++
      if @x >= @maze.width-1
        @x = 1
        @y++

        if @y >= @maze.height-1
          @state = @JOIN
          @eventAt @x, @y
        
  joinStep: ->
    while @edges.length > 0
      edge = @edges.pop()

      nx = edge.x + Maze.Direction.dx[edge.direction]
      ny = edge.y + Maze.Direction.dy[edge.direction]

      set1 = @sets[edge.y][edge.x]
      set2 = @sets[ny][nx]

      if @maze.isWeave? && @weaveMode == "onePhase" && @maze.isPerpendicular(nx, ny, edge.direction)
        nx2 = nx + Maze.Direction.dx[edge.direction]
        ny2 = ny + Maze.Direction.dy[edge.direction]
        set3 = null

        for index in [0...@edges.length]
          edge2 = @edges[index]
          if edge2.x == nx && edge2.y == ny && edge2.direction == edge.direction
            @edges.splice(index, 1)
            set3 = @sets[ny2][nx2]
            break

        if set3 && !set1.isConnectedTo set3
          @connect edge.x, edge.y, nx2, ny2, edge.direction
          @performThruWeave nx, ny
          @updateAt nx, ny
          break
        else if !set1.isConnectedTo set2
          @connect edge.x, edge.y, nx, ny, edge.direction
          break

      else if !set1.isConnectedTo set2
        @connect edge.x, edge.y, nx, ny, edge.direction
        break

  step: ->
    switch @state
      when @WEAVE then @weaveStep()
      when @JOIN  then @joinStep()

    @edges.length > 0


class Maze.Algorithms.Kruskal.Tree
  constructor: -> @up = null
  root: -> if @up then @up.root() else this
  isConnectedTo: (tree) -> @root() == tree.root()
  connect: (tree) -> tree.root().up = this
