{print} = require 'util'
{spawn} = require 'child_process'
fs      = require 'fs'

task 'build', 'Build lib/ from src/', ->
  coffee = spawn 'coffee', ['-c', '--bare', '-o', 'lib', 'src']
  coffee.stdout.on 'data', (data) -> print data.toString()
  coffee.stderr.on 'data', (data) -> print data.toString()

task 'concat', 'Merge all generated Javascript files into a single file, maze-all.js', ->
  priorities = "lib/mersenne.js": 1, "lib/maze.js": 2, "lib/widget.js": 3, "lib/algorithms/growing_binary_tree.js": 20

  sources = ("lib/#{entry}" for entry in fs.readdirSync("lib"))
  algorithms = ("lib/algorithms/#{entry}" for entry in fs.readdirSync("lib/algorithms"))
  sources = sources.concat(algorithms)
  sources = sources.sort (a,b) -> (priorities[a] || 10) - (priorities[b] || 10)

  output = fs.openSync("maze-all.js", "w")
  for source in sources
    if source.match(/\.js$/)
      fs.writeSync(output, "// ------ #{source} -------\n")
      fs.writeSync(output, fs.readFileSync(source) + "\n")
  fs.closeSync(output)

task 'minify', 'Concat and minify all generated Javascript files using YUICompressor', ->
  invoke 'concat'
  fs.open "maze-minified.js", "w", (err, fd) ->
    yui = spawn 'yuicompressor', ['maze-all.js']
    yui.stdout.on 'data', (data) -> fs.write(fd, data.toString())
    yui.stderr.on 'data', (data) -> print data.toString()
    yui.on 'exit', (code) -> fs.close(fd)

task 'clean', 'Clean up generated artifacts', ->
  try
    for js in fs.readdirSync("lib/algorithms")
      print "cleaning `lib/algorithms/#{js}'\n"
      fs.unlink "lib/algorithms/#{js}"

    fs.rmdir "lib/algorithms"
  catch error
    # ignore

  try
    for js in fs.readdirSync("lib")
      print "cleaning `lib/#{js}'\n"
      fs.unlink "lib/#{js}"

    fs.rmdir "lib"
  catch error
    # ignore

  for js in fs.readdirSync(".")
    if js == "maze-all.js" || js == "maze-minified.js"
      print "cleaning `#{js}'\n"
      fs.unlink js
