## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
import System.Collections
#import System.Reflection
import UnityEngine


[RequireComponent(NEventPlug)]
class NAbilityDock (MonoBehaviour, IEnumerable):
	public abilities as (NAbilityBase) = array(NAbilityBase, 0)
	
	
	def Awake():
		for ability in abilities:
			ability.owner = gameObject
	
	
	def HasAbility(abilityType as Type) as bool:
		for ability as NAbilityBase in abilities:
			if ability.GetType() == abilityType:
				return true
		return false
	
	def GetAbility(abilityType as Type) as NAbilityBase:
		for ability as NAbilityBase in abilities:
			if ability.GetType() == abilityType:
				return ability
		return null
	
	def AddAbility(abilityType as Type) as NAbilityBase:
		assert abilityType.IsSubclassOf(NAbilityBase)
		AddAbility( ScriptableObject.CreateInstance(abilityType.ToString()) )
	
	def AddAbility(abilityToAdd as NAbilityBase) as NAbilityBase:
		abilityType as Type = abilityToAdd.GetType()
		assert not HasAbility(abilityType)
		abilityToAdd.owner = gameObject
		abilities += (abilityToAdd,)
	
	
	# IEnumerable
	
	def GetEnumerator() as IEnumerator:
		return Enumerator(abilities);
	
	class Enumerator (IEnumerator):
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
