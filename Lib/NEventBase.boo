## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
#import System.Reflection
import UnityEngine


abstract class NEventBase (ScriptableObject):
	[Getter(name)]
	final _name as string
	
	messageName as string:
		get:
			return "On${name}"
	
	
	def constructor():
		# figure out the name from the class's name
		typeName as string = self.GetType().Name
		assert typeName.EndsWith('Event'), "\"${typeName}\" (which should be a derived from \"NEventBase\") must end with \"Event\""
		_name = typeName.Remove( typeName.LastIndexOf('Event') )
	
	
	# When sub-classing, add any data you like!