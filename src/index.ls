export class Just
  (value) -> @val = value
  map: (fn) ->
    new Just fn @val
  chain: (fn) ->
    fn @val
  value: -> @val

export Nothing =
  map: -> @
  chain: -> @
  value: -> @


export class Err
  (msg) -> @msg = msg
  map: -> @
  chain: -> @
  value: -> @msg

export class Task
  (action) ->
    @action = action

  fork: (err, succ) ->
    @action err, succ

  chain: (fn) ->
    new Task (reject, resolve) ~>
      @fork reject, (data) -> fn data .fork reject, resolve

  map: (fn) ->
    @chain (x) -> Task.succeed fn x

Task.succeed = (v) -> new Task (_, succ) -> succ v
Task.fail = (v) -> new Task (err) -> err v
