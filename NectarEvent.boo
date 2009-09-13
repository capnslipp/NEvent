## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
import UnityEngine


final class NectarEvent:
	public data as INectarNote
	
	
	name as string:
		get:
			return data.name
	
	messageName as string:
		get:
			return "On${name}"
	
	
	def constructor(eventName as string, noteValue as object):
		self(CreateNote(eventName, noteValue))
	
	def constructor(dataNote as INectarNote):
		data = dataNote
		
		dataTypeName as string = data.GetType().Name
		assert dataTypeName.EndsWith('Note')
		assert data.name == dataTypeName.Remove( dataTypeName.LastIndexOf('Note') )
		
	static def CreateNote(eventName as string, noteValue as object) as INectarNote:
		noteType = Type.GetType("${eventName}Note", true)
		note = System.Activator.CreateInstance(noteType, (noteValue) as (object))
		return note
	
	
	enum Scope:
		Local # sender GameObject
		Children # sender & children
		Parent # sender & parent
		Ancestors # sender, parent, upwards
		Specific # sender & a specific GameObject
		Named # sender & a named GameObject
		Tagged # sender & all tagged GameObjects
		Global # all GameObjects; only use for testing!!!
	
	scope as Scope
	
	scopeSpecificGO as GameObject
	scopeName as string
	scopeTag as string
	
	
	def Send(sender as GameObject):
		if scope == Scope.Local:
			sender.SendMessage(messageName, data.GetValue(), SendMessageOptions.DontRequireReceiver)
			
		elif scope == Scope.Children:
			sender.BroadcastMessage(messageName, data.GetValue(), SendMessageOptions.DontRequireReceiver)
			
		elif scope == Scope.Parent:
			sender.SendMessage(messageName, data.GetValue(), SendMessageOptions.DontRequireReceiver)
			sender.transform.parent.SendMessage(messageName, data.GetValue(), SendMessageOptions.DontRequireReceiver)
			
		elif scope == Scope.Ancestors:
			sender.transform.SendMessageUpwards(messageName, data.GetValue(), SendMessageOptions.DontRequireReceiver)
			
		elif scope == Scope.Specific:
			sender.SendMessage(messageName, data.GetValue(), SendMessageOptions.DontRequireReceiver)
			scopeSpecificGO.SendMessage(messageName, data.GetValue(), SendMessageOptions.DontRequireReceiver)
			
		elif scope == Scope.Named:
			sender.SendMessage(messageName, data.GetValue(), SendMessageOptions.DontRequireReceiver)
			GameObject.Find(scopeName).SendMessage(messageName, data.GetValue(), SendMessageOptions.DontRequireReceiver)
			
		elif scope == Scope.Tagged:
			sender.SendMessage(messageName, data.GetValue(), SendMessageOptions.DontRequireReceiver)
			
			taggedGOs = GameObject.FindGameObjectsWithTag(scopeTag)
			for taggedGO in taggedGOs:
				taggedGO.SendMessage(messageName, data.GetValue(), SendMessageOptions.DontRequireReceiver)
			
		elif scope == Scope.Global:
			GameObject.Find('/').BroadcastMessage(messageName, data.GetValue(), SendMessageOptions.DontRequireReceiver)
			
		else:
			assert "unknown ${self.GetType()}.Scope ${scope.ToString()}"
