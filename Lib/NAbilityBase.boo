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
	_abilityOwner as GameObject
	abilityOwner:
		set:
			assert value is not null
			_abilityOwner = value
	
	
	def constructor():
		assert self.GetType() != NAbilityBase, "${self.GetType().FullName} cannot be instantiated directly."
		
		# figure out the name from the class's name
		typeName as string = self.GetType().Name
		assert typeName.EndsWith('Ability')
		_abilityName = typeName.Remove( typeName.LastIndexOf('Ability') )
	
	
	final def OnEnable():
		Awake()
	
	
	
	# convenience methods
	
	virtual def Awake():
		pass
	
	
	
	# convenience properties
	
	gameObject as GameObject:
		get:
			assert _abilityOwner is not null
			return _abilityOwner
	
	
	
	# When sub-classing, add any data you like!
