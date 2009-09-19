#import UnityEngine


class NEvent_TestAbility (NAbilityBase):
	_testEventAction as NEventAction = NEventAction(NEvent_TestEvent)
	public scope as NEventAction.Scope = NEventAction.Scope.Local
	
	public initialValue as int
	
	_value as int = 0
	value as int:
		get:
			return _value
		set:
			_value = value
			initialValue = value
			_testEventAction.scope = scope
			_testEventAction.Send(gameObject, _value)
	
	def constructor():
		_value = initialValue
