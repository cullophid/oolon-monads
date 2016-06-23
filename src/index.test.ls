test = require 'tape'
sinon = require 'sinon'
{Just, Nothing, Err, Task} = require './index'

chain = (fn, monad) --> monad.chain fn
map = (fn, monad) --> monad.map fn

test 'Just should implement map', (t) ->
  t.plan 3
  fn = sinon.spy (+ 1)

  monad = map fn, new Just 1

  t.equals fn.calledOnce, true
  t.deepEqual fn.args[0], [1]
  t.equals monad.value!, 2

test 'Just should implement chain', (t) ->
  t.plan 3
  fn = sinon.spy (n) -> new Just n + 1
  monad = chain fn, new Just 1

  t.equals fn.calledOnce, true
  t.deepEqual fn.args[0], [1]
  t.equals monad.value!, 2

test 'Nothing should implement map', (t) ->
  t.plan 2

  fn = sinon.spy!
  monad = map fn, Nothing

  t.equals fn.called, false
  t.equals monad.value!, Nothing

test 'Nothing should implement chain', (t) ->
  t.plan 2

  fn = sinon.spy!
  monad = chain fn, Nothing

  t.equals fn.called, false
  t.equals monad.value!, Nothing

test 'Err should implement chain', (t) ->
  t.plan 2

  fn = sinon.spy!
  monad = chain fn, new Err "ERROR"

  t.equals fn.called, false
  t.equals monad.value!, "ERROR"

test 'Err should implement map', (t) ->
  t.plan 2

  fn = sinon.spy!
  monad = map fn, new Err "ERROR"

  t.equals fn.called, false
  t.equals monad.value!, "ERROR"

test 'Task should not call the handler until fork is called', (t) ->
    t.plan 1
    handler = sinon.spy (err, succ) -> succ 1
    mapFn = sinon.spy (+ 1)
    chainFn = sinon.spy (n) -> Task.succeed n + 1
    err = sinon.spy!
    succ = sinon.spy!

    monad = map mapFn
      <| chain chainFn
      <| new Task handler

    t.equals handler.called, false


test 'Task should implement map', (t) ->
  t.plan 5
  fn = sinon.spy (+ 1)
  handler = sinon.spy (err, succ) -> succ 1
  err = sinon.spy!
  succ = sinon.spy!

  monad = map fn, new Task handler
  monad.fork err, succ

  t.equals fn.calledOnce, true
  t.deepEqual fn.args[0], [1]

  t.equals err.called, false
  t.equals succ.calledOnce, true
  t.deepEqual succ.args[0], [2]

test 'Task should implement chain', (t) ->
  t.plan 5
  fn = sinon.spy (n) -> Task.succeed n + 1
  handler = sinon.spy (err, succ) -> succ 1
  err = sinon.spy!
  succ = sinon.spy!

  monad = chain fn, new Task handler

  monad.fork err, succ

  t.equals fn.calledOnce, true
  t.deepEqual fn.args[0], [1]

  t.equals err.called, false
  t.equals succ.calledOnce, true
  t.deepEqual succ.args[0], [2]
