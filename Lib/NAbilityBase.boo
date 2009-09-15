## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
#import System.Reflection
import UnityEngine


abstract class NAbilityBase (MonoBehaviour):
	[Getter(abilityName)]
	final _abilityName as string
	
	
	def constructor():
		# figure out the name from the class's name
		typeName as string = self.GetType().Name
		assert typeName.EndsWith('Ability')
		_abilityName = typeName.Remove( typeName.LastIndexOf('Ability') )
	
	
	# When sub-classing, add any data you like!
