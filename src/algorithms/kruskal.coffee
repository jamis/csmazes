###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze.Algorithms.Kruskal extends Maze.Algorithm
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

  step: ->
    while @edges.length > 0
      edge = @edges.pop()

      nx = edge.x + Maze.Direction.dx[edge.direction]
      ny = edge.y + Maze.Direction.dy[edge.direction]

      set1 = @sets[edge.y][edge.x]
      set2 = @sets[ny][nx]

      unless set1.isConnectedTo set2
        set1.connect set2

        @maze.carve edge.x, edge.y, edge.direction
        @callback @maze, edge.x, edge.y

        @maze.carve nx, ny, Maze.Direction.opposite[edge.direction]
        @callback @maze, nx, ny

        break

    @edges.length > 0

class Maze.Algorithms.Kruskal.Tree
  constructor: -> @up = null
  root: -> if @up then @up.root() else this
  isConnectedTo: (tree) -> @root() == tree.root()
  connect: (tree) -> tree.root().up = this
