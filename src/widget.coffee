###
Author: Jamis Buck <jamis@jamisbuck.org>
License: Public domain, baby. Knock yourself out.

The original CoffeeScript sources are always available on GitHub:
http://github.com/jamis/csmazes
###

Maze.createWidget = (algorithm, width, height, options) ->
  options ?= {}

  updateWalls = (maze, x, y, classes) ->
    classes.push "e" if maze.isEast(x, y)
    classes.push "w" if maze.isWest(x, y)
    classes.push "s" if maze.isSouth(x, y)
    classes.push "n" if maze.isNorth(x, y)
    classes.push "u" if maze.isUnder(x, y)

  ACTIONS =
    AldousBroder: (maze, x, y, classes) ->
      if maze.algorithm.isCurrent(x, y)
        classes.push "cursor"
      else if not maze.isBlank(x, y)
        classes.push "in"
        updateWalls maze, x, y, classes

    GrowingTree: (maze, x, y, classes) ->
      if not maze.isBlank(x, y)
        if maze.algorithm.inQueue(x, y)
          classes.push "f"
        else
          classes.push "in"
        updateWalls maze, x, y, classes
    
    GrowingBinaryTree: (maze, x, y, classes) ->
      ACTIONS.GrowingTree(maze, x, y, classes)

    HuntAndKill: (maze, x, y, classes) ->
      if maze.algorithm.isCurrent(x, y)
        classes.push "cursor"
      unless maze.isBlank(x, y)
        classes.push "in"
        updateWalls maze, x, y, classes
        
    Prim: (maze, x, y, classes) ->
      if maze.algorithm.isFrontier(x, y)
        classes.push "f"
      else if maze.algorithm.isInside(x, y)
        classes.push "in"
        updateWalls maze, x, y, classes

    RecursiveBacktracker: (maze, x, y, classes) ->
      if maze.algorithm.isStack(x, y)
        classes.push "f"
      else
        classes.push "in"
      updateWalls maze, x, y, classes

    RecursiveDivision: (maze, x, y, classes) ->
      updateWalls(maze, x, y, classes)

    Wilson: (maze, x, y, classes) ->
      if maze.algorithm.isCurrent(x, y)
        classes.push "cursor"
        updateWalls maze, x, y, classes
      else if not maze.isBlank(x, y)
        classes.push "in"
        updateWalls maze, x, y, classes
      else if maze.algorithm.isVisited(x, y)
        classes.push "f"

    Houston: (maze, x, y, classes) ->
      if maze.algorithm.worker.isVisited?
        ACTIONS.Wilson(maze, x, y, classes)
      else
        ACTIONS.AldousBroder(maze, x, y, classes)

    default: (maze, x, y, classes) ->
      unless maze.isBlank(x, y)
        classes.push "in"
        updateWalls maze, x, y, classes

  updateCallback = (maze, x, y) ->
    classes = []
    (ACTIONS[algorithm] || ACTIONS.default)(maze, x, y, classes)
    cell = document.getElementById("#{maze.element.id}_y#{y}x#{x}")
    cell.className = classes.join(" ")

  eventCallback = (maze, x, y) ->
    maze.element.mazePause() if maze.element.quickStep

  id = options.id || algorithm.toLowerCase()
  options.interval ?= 50

  mazeClass = "maze"
  mazeClass += " " + options.class if options.class

  gridClass = "grid"
  gridClass += " invert" if options.wallwise
  gridClass += " padded" if options.padded

  if options.watch ? true
    watch = "<a id='#{id}_watch' href='#' onclick='document.getElementById(\"#{id}\").mazeQuickStep(); return false;'>Watch</a>"
  else
    watch = ""

  html = """
         <div id="#{id}" class="#{mazeClass}">
           <div id="#{id}_grid" class="#{gridClass}"></div>
           <div class="operations">
             <a id="#{id}_reset" href="#" onclick="document.getElementById('#{id}').mazeReset(); return false;">Reset</a>
             <a id="#{id}_step" href="#" onclick="document.getElementById('#{id}').mazeStep(); return false;">Step</a>
             #{watch}
             <a id="#{id}_run" href="#" onclick="document.getElementById('#{id}').mazeRun(); return false;">Run</a>
           </div>
         </div>
         """

  document.write html
  element = document.getElementById(id)

  element.addClassName = (el, name) ->
    classNames = el.className.split(" ")
    for className in classNames
      return if className == name
    el.className += " " + name

  element.removeClassName = (el, name) ->
    if el.className.length > 0
      classNames = el.className.split(" ")
      el.className = ""
      for className in classNames
        if className != name
          el.className += " " if el.className.length > 0
          el.className += className

  element.mazePause = ->
    if @mazeStepInterval?
      clearInterval @mazeStepInterval
      @mazeStepInterval = null
      @quickStep = false
      return true

  element.mazeRun = ->
    unless @mazePause()
      @mazeStepInterval = setInterval((=> @mazeStep()), options.interval)

  element.mazeStep = ->
    unless @maze.step()
      @mazePause()
      @addClassName document.getElementById("#{@id}_step"), "disabled"
      @addClassName document.getElementById("#{@id}_watch"), "disabled" if options.watch ? true
      @addClassName document.getElementById("#{@id}_run"), "disabled"

  element.mazeQuickStep = ->
    @quickStep = true
    @mazeRun()

  element.mazeReset = ->
    @mazePause()

    if typeof options.input == "function"
      value = options.input()
    else
      value = options.input

    @maze = new Maze(width, height, Maze.Algorithms[algorithm], {
      seed: options.seed,
      rng: options.rng, input: value, weave: options.weave, weaveMode: options.weaveMode,
      weaveDensity: options.weaveDensity
    })

    @maze.element = this
    @maze.onUpdate(updateCallback)
    @maze.onEvent(eventCallback)

    grid = ""
    for y in [0...@maze.height]
      row_id = "#{@id}_y#{y}"
      grid += "<div class='row' id='#{row_id}'>"
      for x in [0...@maze.width]
        grid += "<div id='#{row_id}x#{x}'>"
        if options.padded
          grid += "<div class='np'></div>"
          grid += "<div class='wp'></div>"
          grid += "<div class='ep'></div>"
          grid += "<div class='sp'></div>"
          grid += "<div class='c'></div>"
        grid += "</div>"
      grid += "</div>"

    gridElement = document.getElementById("#{@id}_grid")
    gridElement.innerHTML = grid

    @removeClassName document.getElementById("#{@id}_step"), "disabled"
    @removeClassName document.getElementById("#{@id}_watch"), "disabled" if options.watch ? true
    @removeClassName document.getElementById("#{@id}_run"), "disabled"

  element.mazeReset()



Maze.createCanvasWidget = (algorithm, width, height, options) ->
  options ?= {}

  styles = options.styles ? {}

  styles.blank  ?= "#ccc"
  styles.f      ?= "#faa"
  styles.a      ?= "#faa"
  styles.b      ?= "#afa"
  styles.in     ?= "#fff"
  styles.cursor ?= "#7f7"
  styles.wall   ?= "#000"

  COLORS =
    AldousBroder: (maze, x, y) ->
      if maze.algorithm.isCurrent(x, y)
        styles.cursor
      else if not maze.isBlank(x, y)
        styles.in

    GrowingTree: (maze, x, y) ->
      if not maze.isBlank(x, y)
        if maze.algorithm.inQueue(x, y)
          styles.f
        else
          styles.in

    GrowingBinaryTree: (maze, x, y) ->
      COLORS.GrowingTree(maze, x, y)

    HuntAndKill: (maze, x, y) ->
      if maze.algorithm.isCurrent(x, y)
        styles.cursor
      else if not maze.isBlank(x, y)
        styles.in

    Prim: (maze, x, y) ->
      if maze.algorithm.isFrontier(x, y)
        styles.f
      else if maze.algorithm.isInside(x, y)
        styles.in

    RecursiveBacktracker: (maze, x, y) ->
      if maze.algorithm.isStack(x, y)
        styles.f
      else if not maze.isBlank(x, y)
        styles.in

    RecursiveDivision: (maze, x, y) ->
      # nothing to do here--no fill styles!

    Wilson: (maze, x, y) ->
      if maze.algorithm.isCurrent(x, y)
        styles.cursor
      else if not maze.isBlank(x, y)
        styles.in
      else if maze.algorithm.isVisited(x, y)
        styles.f

    Houston: (maze, x, y) ->
      if maze.algorithm.worker?
        if maze.algorithm.worker.isVisited?
          COLORS.Wilson(maze, x, y)
        else
          COLORS.AldousBroder(maze, x, y)

    BlobbyDivision: (maze, x, y) ->
      switch maze.algorithm.stateAt(x, y)
        when "blank"  then styles.blank
        when "in"     then styles.in
        when "active" then styles.f
        when "a"      then styles.a
        when "b"      then styles.b

    default: (maze, x, y) ->
      unless maze.isBlank(x, y)
        styles.in

  drawLine = (ctx, x1, y1, x2, y2) ->
    ctx.moveTo(x1, y1)
    ctx.lineTo(x2, y2)

  drawCell = (maze, x, y) ->
    px = x * maze.cellWidth
    py = y * maze.cellHeight

    wmpx = if x == 0 then px + 0.5 else px - 0.5
    nmpy = if y == 0 then py + 0.5 else py - 0.5
    empx = px - 0.5
    smpy = py - 0.5

    colors = COLORS[algorithm] || COLORS.default
    color = colors(maze, x, y)
    color ?= (if options.wallwise then styles.in else styles.blank)

    maze.context.fillStyle = color
    maze.context.fillRect(px, py, maze.cellWidth, maze.cellHeight)

    maze.context.beginPath()

    # west && options.wallwise || !west && !options.wallwise
    # -> same as testing equality

    if maze.isWest(x, y) == options.wallwise?
      drawLine(maze.context, wmpx, py, wmpx, py+maze.cellHeight)

    if maze.isEast(x, y) == options.wallwise?
      drawLine(maze.context, empx + maze.cellWidth, py, empx + maze.cellWidth, py+maze.cellHeight)

    if maze.isNorth(x, y) == options.wallwise?
      drawLine(maze.context, px, nmpy, px+maze.cellWidth, nmpy)

    if maze.isSouth(x, y) == options.wallwise?
      drawLine(maze.context, px, smpy + maze.cellHeight, px+maze.cellWidth, smpy + maze.cellHeight)

    maze.context.closePath()
    maze.context.stroke()

  drawCellPadded = (maze, x, y) ->
    px1 = x * maze.cellWidth
    px2 = px1 + maze.insetWidth - 0.5
    px4 = px1 + maze.cellWidth - 0.5
    px3 = px4 - maze.insetWidth

    py1 = y * maze.cellHeight
    py2 = py1 + maze.insetHeight - 0.5
    py4 = py1 + maze.cellHeight - 0.5
    py3 = py4 - maze.insetHeight

    px1 = if x == 0 then px1 + 0.5 else px1 - 0.5
    py1 = if y == 0 then py1 + 0.5 else py1 - 0.5

    colors = COLORS[algorithm] || COLORS.default
    color = colors(maze, x, y)
    color ?= (if options.wallwise then styles.in else styles.blank)

    maze.context.fillStyle = color
    maze.context.fillRect(px2-0.5, py2-0.5, px3-px2+1, py3-py2+1)

    maze.context.beginPath()

    if maze.isWest(x, y) || maze.isUnder(x, y)
      maze.context.fillRect(px1-0.5, py2-0.5, px2-px1+1, py3-py2+1)
      drawLine(maze.context, px1-1, py2, px2, py2)
      drawLine(maze.context, px1-1, py3, px2, py3)
    if !maze.isWest(x, y) 
      drawLine(maze.context, px2, py2, px2, py3)

    if maze.isEast(x, y) || maze.isUnder(x, y)
      maze.context.fillRect(px3-0.5, py2-0.5, px4-px3+1, py3-py2+1)
      drawLine(maze.context, px3, py2, px4+1, py2)
      drawLine(maze.context, px3, py3, px4+1, py3)
    if !maze.isEast(x, y)
      drawLine(maze.context, px3, py2, px3, py3)

    if maze.isNorth(x, y) || maze.isUnder(x, y)
      maze.context.fillRect(px2-0.5, py1-0.5, px3-px2+1, py2-py1+1)
      drawLine(maze.context, px2, py1-1, px2, py2)
      drawLine(maze.context, px3, py1-1, px3, py2)
    if !maze.isNorth(x, y)
      drawLine(maze.context, px2, py2, px3, py2)

    if maze.isSouth(x, y) || maze.isUnder(x, y)
      maze.context.fillRect(px2-0.5, py3-0.5, px3-px2+1, py4-py3+1)
      drawLine(maze.context, px2, py3, px2, py4+1)
      drawLine(maze.context, px3, py3, px3, py4+1)
    if !maze.isSouth(x, y)
      drawLine(maze.context, px2, py3, px3, py3)

    maze.context.closePath()
    maze.context.stroke()

  drawMaze = (maze) ->
    for row in [0...maze.height] by 1
      for col in [0...maze.width] by 1
        if options.padded
          drawCellPadded(maze, col, row)
        else
          drawCell(maze, col, row)

  updateCallback = (maze, x, y) ->
    if options.padded
      drawCellPadded(maze, x, y)
    else
      drawCell(maze, x, y)

  eventCallback = (maze, x, y) ->
    maze.element.mazePause() if maze.element.quickStep

  id = options.id || algorithm.toLowerCase()
  options.interval ?= 50

  mazeClass = "maze"
  mazeClass += " " + options.class if options.class

  gridClass = "grid"
  gridClass += " invert" if options.wallwise
  gridClass += " padded" if options.padded

  if options.watch ? true
    watch = "<a id='#{id}_watch' href='#' onclick='document.getElementById(\"#{id}\").mazeQuickStep(); return false;'>Watch</a>"
  else
    watch = ""

  html = """
         <div id="#{id}" class="#{mazeClass}">
           <canvas id="#{id}_canvas" width="210" height="210" class="#{gridClass}"></canvas>
           <div class="operations">
             <a id="#{id}_reset" href="#" onclick="document.getElementById('#{id}').mazeReset(); return false;">Reset</a>
             <a id="#{id}_step" href="#" onclick="document.getElementById('#{id}').mazeStep(); return false;">Step</a>
             #{watch}
             <a id="#{id}_run" href="#" onclick="document.getElementById('#{id}').mazeRun(); return false;">Run</a>
           </div>
         </div>
         """

  document.write html
  element = document.getElementById(id)

  element.addClassName = (el, name) ->
    classNames = el.className.split(" ")
    for className in classNames
      return if className == name
    el.className += " " + name

  element.removeClassName = (el, name) ->
    if el.className.length > 0
      classNames = el.className.split(" ")
      el.className = ""
      for className in classNames
        if className != name
          el.className += " " if el.className.length > 0
          el.className += className

  element.mazePause = ->
    if @mazeStepInterval?
      clearInterval @mazeStepInterval
      @mazeStepInterval = null
      @quickStep = false
      return true

  element.mazeRun = ->
    unless @mazePause()
      @mazeStepInterval = setInterval((=> @mazeStep()), options.interval)

  element.mazeStep = ->
    unless @maze.step()
      @mazePause()
      @addClassName document.getElementById("#{@id}_step"), "disabled"
      @addClassName document.getElementById("#{@id}_watch"), "disabled" if options.watch ? true
      @addClassName document.getElementById("#{@id}_run"), "disabled"

  element.mazeQuickStep = ->
    @quickStep = true
    @mazeRun()

  element.mazeReset = ->
    @mazePause()

    if typeof options.input == "function"
      value = options.input()
    else
      value = options.input

    if typeof options.threshold == "function"
      threshold = options.threshold()
    else
      threshold = options.threshold

    growSpeed = Math.round(Math.sqrt(width * height))
    wallSpeed = Math.round((if width < height then width else height) / 2)

    @maze = new Maze(width, height, Maze.Algorithms[algorithm], {
      seed: options.seed,
      rng: options.rng, input: value, weave: options.weave, weaveMode: options.weaveMode,
      weaveDensity: options.weaveDensity, threshold: threshold,
      growSpeed: growSpeed, wallSpeed: wallSpeed
    })

    canvas = document.getElementById("#{@id}_canvas")

    @maze.element = this
    @maze.canvas = canvas
    @maze.context = canvas.getContext('2d')
    @maze.cellWidth = Math.floor(canvas.width / @maze.width)
    @maze.cellHeight = Math.floor(canvas.height / @maze.height)

    if options.padded
      inset = options.inset ? 0.1
      @maze.insetWidth = Math.ceil(inset * @maze.cellWidth)
      @maze.insetHeight = Math.ceil(inset * @maze.cellHeight)

    @maze.onUpdate(updateCallback)
    @maze.onEvent(eventCallback)

    @maze.context.clearRect(0, 0, canvas.width, canvas.height)

    @removeClassName document.getElementById("#{@id}_step"), "disabled"
    @removeClassName document.getElementById("#{@id}_watch"), "disabled" if options.watch ? true
    @removeClassName document.getElementById("#{@id}_run"), "disabled"

    drawMaze(@maze)

  element.mazeReset()
