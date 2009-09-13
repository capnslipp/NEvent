## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
#import System.Reflection
#import UnityEngine


abstract class NectarNoteBase:
	[Getter(name)]
	_name as string
	
	
	def constructor():
		# figure out the name from the class's name
		typeName as string = self.GetType().Name
		assert typeName.EndsWith('Note')
		_name = typeName.Remove( typeName.LastIndexOf('Note') )
