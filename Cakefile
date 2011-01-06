{print} = require 'sys'
{spawn} = require 'child_process'

task 'build', 'Build lib/ from src/', ->
  coffee = spawn 'coffee', ['-c', '--no-wrap', '-o', 'lib', 'src']
  coffee.stdout.on 'data', (data) -> print data.toString()
  coffee.stderr.on 'data', (data) -> print data.toString()
