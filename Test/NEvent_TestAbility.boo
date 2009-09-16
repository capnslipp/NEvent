#import UnityEngine


class NEventTestAbility (NAbilityBase):
	_testEventAction as NEventAction = NEventAction(NEventTestEvent)
	
	_value as int = 0
	value:
		get:
			return _value
		set:
			_value = value
			_testEventAction.Send(gameObject, _value)
