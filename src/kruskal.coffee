###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze.Kruskal extends Maze
  constructor: (width, height, options) ->
    super(width, height, options)

    @sets = []
    @edges = []

    y = 0
    while y < @height
      @sets.push([])
      x = 0
      while x < @width
        @sets[y].push new Maze.Kruskal.Tree()
        @edges.push {x: x, y: y, direction: Maze.Direction.N} if y > 0
        @edges.push {x: x, y: y, direction: Maze.Direction.W} if x > 0
        x += 1
      y += 1

    @randomizeList(@edges)

  step: () ->
    while @edges.length > 0
      edge = @edges.pop()

      nx = edge.x + Maze.Direction.dx[edge.direction]
      ny = edge.y + Maze.Direction.dy[edge.direction]

      set1 = @sets[edge.y][edge.x]
      set2 = @sets[ny][nx]

      unless set1.isConnectedTo set2
        set1.connect set2

        @carve edge.x, edge.y, edge.direction
        @callback this, edge.x, edge.y

        @carve nx, ny, Maze.Direction.opposite[edge.direction]
        @callback this, nx, ny

        break

    @edges.length > 0

class Maze.Kruskal.Tree
  constructor: () -> @up = null
  root: () -> if @up then @up.root() else this
  isConnectedTo: (tree) -> @root() == tree.root()
  connect: (tree) -> tree.root().up = this
