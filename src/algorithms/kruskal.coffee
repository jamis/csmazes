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

  connect: (set1, set2, edge, nx, ny) =>
    set1.connect set2

    @maze.carve edge.x, edge.y, edge.direction
    @updateAt edge.x, edge.y

    @maze.carve nx, ny, Maze.Direction.opposite[edge.direction]
    @updateAt nx, ny

  step: ->
    while @edges.length > 0
      edge = @edges.pop()

      nx = edge.x + Maze.Direction.dx[edge.direction]
      ny = edge.y + Maze.Direction.dy[edge.direction]

      set1 = @sets[edge.y][edge.x]
      set2 = @sets[ny][nx]

      if @maze.isWeave && @maze.isPerpendicular(nx, ny, edge.direction)
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
          @connect set1, set3, edge, nx2, ny2
          @performThruWeave nx, ny
          @updateAt nx, ny
          break
        else if !set1.isConnectedTo set2
          @connect set1, set2, edge, nx, ny
          break

      else if !set1.isConnectedTo set2
        @connect set1, set2, edge, nx, ny
        break

    @edges.length > 0

class Maze.Algorithms.Kruskal.Tree
  constructor: -> @up = null
  root: -> if @up then @up.root() else this
  isConnectedTo: (tree) -> @root() == tree.root()
  connect: (tree) -> tree.root().up = this
