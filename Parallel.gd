extends Node
class_name Parallel

signal done()

var _total = 0
var _completed = 0
var _callables: Array[Callable] = []

## Add some awaitable lambda's, then when all are added
## call start() to start all in parallel. When they are
## all done, the done() signal will be called
	
func add_awaitable(awaitable: Callable) -> void:
	_callables.append(awaitable)

func start() -> void:
	_total = len(_callables)
	for callable in _callables:
		var lam = func():
			await callable.call()
			_done()
		lam.call()
	
func _done() -> void:
	_completed += 1
	if _completed == _total:
		done.emit()
