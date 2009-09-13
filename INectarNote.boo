## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


#import System.Reflection
#import UnityEngine


interface INectarNote:
	# meant to be implemented like:
	# 	[Getter(name)]
	# 	static _name as string = 'NameGoesHere'
	name as string:
		get:
			pass
