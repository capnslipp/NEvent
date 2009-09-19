## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
#import System.Reflection
import UnityEngine


abstract class NAbilityBase (ScriptableObject):
	[Getter(abilityName)]
	final _abilityName as string
	
	
	# allows derived classes access to the handy GameObject and Component accessors
	_owner as GameObject
	owner:
		set:
			assert value is not null
			_owner = value
	
	
	def constructor():
		assert self.GetType() != NAbilityBase, "${self.GetType().Name} cannot be instantiated directly."
		
		# figure out the name from the class's name
		typeName as string = self.GetType().Name
		assert typeName.EndsWith('Ability')
		_abilityName = typeName.Remove( typeName.LastIndexOf('Ability') )
	
	
	gameObject as GameObject:
		get:
			assert _owner is not null
			return _owner
	
	
	# When sub-classing, add any data you like!
