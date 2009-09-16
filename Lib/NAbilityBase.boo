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
	public owner as GameObject
	
	
	def constructor():
		# figure out the name from the class's name
		typeName as string = self.GetType().Name
		assert typeName.EndsWith('Ability')
		_abilityName = typeName.Remove( typeName.LastIndexOf('Ability') )
	
	
	gameObject as GameObject:
		get:
			assert owner is not null
			return owner
	
	
	# When sub-classing, add any data you like!
