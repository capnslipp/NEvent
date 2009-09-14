## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
#import System.Reflection
#import UnityEngine


abstract class NectarNoteBase:
	[Getter(name)]
	final _name as string
	
	messageName as string:
		get:
			return "On${name}"
	
	
	def constructor():
		# figure out the name from the class's name
		typeName as string = self.GetType().Name
		assert typeName.EndsWith('Note')
		_name = typeName.Remove( typeName.LastIndexOf('Note') )
	
	
	# When sub-classing, add any data you like!