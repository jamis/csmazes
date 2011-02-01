###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

class Maze.Algorithms.GrowingBinaryTree extends Maze.Algorithms.GrowingTree
  runStep: ->
    index = @nextCell()

    cell = @cells.splice(index, 1)[0]
    @maze.uncarve cell.x, cell.y, @QUEUE
    @updateAt cell.x, cell.y

    count = 0
    for direction in @rand.randomDirections()
      nx = cell.x + Maze.Direction.dx[direction]
      ny = cell.y + Maze.Direction.dy[direction]

      if @maze.isValid(nx, ny) && @maze.isBlank(nx, ny)
        @maze.carve cell.x, cell.y, direction
        @maze.carve nx, ny, Maze.Direction.opposite[direction]
        @enqueue nx, ny
        @updateAt cell.x, cell.y
        @updateAt nx, ny
        count += 1
        return if count > 1
