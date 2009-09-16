#import UnityEngine


class NEvent_TestAbility (NAbilityBase):
	_testEventAction as NEventAction = NEventAction(NEvent_TestEvent)
	
	_value as int = 0
	value:
		get:
			return _value
		set:
			_value = value
			_testEventAction.Send(gameObject, _value)
