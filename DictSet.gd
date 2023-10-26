class_name DictSet

# A data structure similar to a dictionary that enforces
# unqiue keys along with unique values. So no key can
# have the same value as another key.
# Note:
# null is special and allowed to be on more than 1 key.

var _hash_set: Array[Variant] = []
var _dict: Dictionary = {}

func assign(key: Variant, value: Variant) -> void:
	if value in _hash_set:
		var k = _dict.find_key(value)
		_dict[k] = null
		_dict[key] = value
	else:
		_hash_set.append(value)
		_dict[key] = value
		
	
func remove(key: Variant) -> void:
	var value = _dict.get(key)
	_dict.erase(key)
	_hash_set.erase(value)
	
	
func try_get(key: Variant) -> Variant:
	return _dict.get(key)
