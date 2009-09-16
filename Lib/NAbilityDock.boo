## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
#import System.Reflection
import UnityEngine


class NAbilityDock (MonoBehaviour, Collections.IEnumerable):
	# keys are Types
	# values are instances of classes derived from NAbilityBase
	_abilities as Hash = {}
	
	
	def HasAbility(abilityType as Type) as bool:
		return _abilities.ContainsKey(abilityType)
	
	def GetAbility(abilityType as Type) as NAbilityBase:
		return _abilities[abilityType]
	
	def AddAbility(abilityType as Type) as NAbilityBase:
		assert abilityType.IsSubclassOf(NAbilityBase)
		AddAbility( ScriptableObject.CreateInstance(abilityType.ToString()) )
	
	def AddAbility(abilityToAdd as NAbilityBase) as NAbilityBase:
		abilityType as Type = abilityToAdd.GetType()
		assert not HasAbility(abilityType)
		abilityToAdd.owner = gameObject
		_abilities[abilityType] = abilityToAdd
	
	
	# Collections.IEnumerable
	
	def GetEnumerator() as Collections.IEnumerator:
		return Enumerator(_abilities.Values);
	
	class Enumerator (Collections.IEnumerator):
		_abilities as (NAbilityBase)
		
		# Enumerators are positioned before the first element until the first MoveNext() call.
		_position as int = -1
		
		def constructor(abilityArray as (NAbilityBase)):
			_abilities = abilityArray
		
		def MoveNext() as bool:
			++_position
			return _position < _abilities.Length
		
		def Reset() as void:
			_position = -1
		
		Current as object:
			get:
				try:
					return _abilities[_position];
				except IndexOutOfRangeException:
					raise InvalidOperationException()
