## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
import System.Reflection
import UnityEngine


abstract class NReactionBase (ScriptableObject):
	[Getter(reactionName)]
	final _reactionName as string
	
	[Getter(eventName)]
	final _eventName as string
	
	
	# allows derived classes access to the handy GameObject and Component accessors
	public owner as GameObject
	
	
	def constructor():
		assert self.GetType() != NReactionBase, "${self.GetType().Name} cannot be instantiated directly."
		
		# figure out the name from the class's name
		typeName as string = self.GetType().Name
		
		onCharIndex as int = typeName.LastIndexOf('On')
		assert onCharIndex != -1
		_reactionName = typeName[:onCharIndex]
		assert not String.IsNullOrEmpty(_reactionName)
		_eventName = typeName[onCharIndex + 2:]
		assert not String.IsNullOrEmpty(_eventName)
		
		methods as (MethodInfo) = self.GetType().GetMethods(BindingFlags.Public | BindingFlags.Instance)
		methodExistsForEvent as bool = false
		for methodInfo as MethodInfo in methods:
			if methodInfo.Name == "On${_eventName}":
				methodExistsForEvent = true
				break
		assert methodExistsForEvent
	
	
	gameObject as GameObject:
		get:
			assert owner is not null
			return owner
