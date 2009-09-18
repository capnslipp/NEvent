## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
import System.Reflection
import UnityEngine


class NEventAction:
	final public noteType as Type
	
	
	[Getter(name)]
	_name as string
	
	
	messageName as string:
		get:
			# @todo: bad, bad, bad; must find a cleaner way to do this!
			return (noteType() as NEventBase).messageName
	
	
	def constructor(aNoteType as string):
		self( Type.GetType(aNoteType) )
	
	def constructor(aNoteType as Type):
		noteType = aNoteType
		assert noteType.IsSubclassOf(NEventBase)
		
		# @todo: bad, bad, bad; must find a cleaner way to do this!
		_name = (noteType() as NEventBase).name
	
	
	enum Scope:
		Local # sender GameObject
		Children # sender & children
		Descendents # sender & descendents
		Parent # sender & parent
		Ancestors # sender, parent, upwards
		Specific # sender & a specific GameObject
		Named # sender & a named GameObject
		Tagged # sender & all tagged GameObjects
		Global # all GameObjects; only use for testing!!!
	
	scope as Scope = Scope.Local
	
	scopeSpecificGO as GameObject
	scopeName as string
	scopeTag as string
	
	
	# @todo: store sender as owner
	def Send(sender as GameObject) as void:
		Send(sender, null)
	
	# @todo: store sender as owner
	def Send(sender as GameObject, noteArg as object) as void:
		Send(sender, (noteArg,))
	
	# @todo: store sender as owner
	def Send(sender as GameObject, noteArgs as (object)) as void:
		assert sender is not null
		
		# create the Event
		
		note as NEventBase = noteType()
		assert note.GetType().IsSubclassOf(NEventBase)
		
		
		# populate the Event's data
		
		noteFields as (FieldInfo) = note.GetType().GetFields(BindingFlags.Public | BindingFlags.Instance)
		assert noteArgs.Length == noteFields.Length
		
		for nI in range(0, noteFields.Length):
			noteField as FieldInfo = noteFields[nI]
			noteField.SetValue(note, noteArgs[nI])
		
		
		# figure out the event's target(s)
		
		targets as (GameObject) = (sender,)
		global as bool = false
		
		if scope == Scope.Local:
			pass
			
		elif scope == Scope.Children:
			for childTransform as Transform in sender.transform:
				targets += (childTransform.gameObject,)
			
		elif scope == Scope.Parent:
			targets += (sender.transform.parent.gameObject,)
			
		elif scope == Scope.Ancestors:
			ancestorRef as Transform = sender.transform.parent
			
			while ancestorRef is not null:
				targets += (ancestorRef.gameObject,)
				ancestorRef = ancestorRef.parent
			
		elif scope == Scope.Specific:
			assert scopeSpecificGO is not null
			
			targets += (scopeSpecificGO,)
			
		elif scope == Scope.Named:
			assert not String.IsNullOrEmpty(scopeName)
			
			targets += (GameObject.Find(scopeName),)
			
		elif scope == Scope.Tagged:
			assert not String.IsNullOrEmpty(scopeTag)
			
			taggedGOs = GameObject.FindGameObjectsWithTag(scopeTag)
			targets += (taggedGOs)
			
		elif scope == Scope.Global:
			targets = array(GameObject, 0)
			global = true
			
		else:
			assert "unknown ${self.GetType()}.Scope ${scope.ToString()}"
		
		
		# send the info off to the Plug (sender)
		
		# @todo: cache the NEventPlug ref
		eventPlug as NEventPlug = sender.GetComponent(NEventPlug)
		
		# if an event plug is available, use it
		if eventPlug is not null:
			eventPlug.PushNEvent(note, targets, global)
		# otherwise, just send the event immediately
		else:
			note.Send(targets, global)
