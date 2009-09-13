## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
import UnityEngine


final class NectarEvent:
	static final kReceiveMethodName = 'NectarReceive'
	
	
	public note as NectarNoteBase
	
	
	name as string:
		get:
			return note.name
	
	messageName as string:
		get:
			return note.messageName
	
	
	def constructor(newNote as NectarNoteBase):
		note = newNote
	
	
	enum Scope:
		Local # sender GameObject
		Children # sender & children
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
	
	
	def Send(sender as GameObject):
		if scope == Scope.Local:
			sender.SendMessage(
				kReceiveMethodName,
				note,
				SendMessageOptions.DontRequireReceiver
			)
			
		elif scope == Scope.Children:
			sender.BroadcastMessage(
				kReceiveMethodName,
				note,
				SendMessageOptions.DontRequireReceiver
			)
			
		elif scope == Scope.Parent:
			sender.SendMessage(
				kReceiveMethodName,
				note,
				SendMessageOptions.DontRequireReceiver
			)
			sender.transform.parent.SendMessage(
				kReceiveMethodName,
				note,
				SendMessageOptions.DontRequireReceiver
			)
			
		elif scope == Scope.Ancestors:
			sender.transform.SendMessageUpwards(
				kReceiveMethodName,
				note,
				SendMessageOptions.DontRequireReceiver
			)
			
		elif scope == Scope.Specific:
			assert scopeSpecificGO is not null
			
			sender.SendMessage(
				kReceiveMethodName,
				note,
				SendMessageOptions.DontRequireReceiver
			)
			scopeSpecificGO.SendMessage(
				kReceiveMethodName,
				note,
				SendMessageOptions.DontRequireReceiver
			)
			
		elif scope == Scope.Named:
			assert not String.IsNullOrEmpty(scopeName)
			
			sender.SendMessage(
				kReceiveMethodName,
				note,
				SendMessageOptions.DontRequireReceiver
			)
			GameObject.Find(scopeName).SendMessage(
				kReceiveMethodName,
				note,
				SendMessageOptions.DontRequireReceiver
			)
			
		elif scope == Scope.Tagged:
			assert not String.IsNullOrEmpty(scopeTag)
			
			sender.SendMessage(
				kReceiveMethodName,
				note,
				SendMessageOptions.DontRequireReceiver
			)
			
			taggedGOs = GameObject.FindGameObjectsWithTag(scopeTag)
			for taggedGO in taggedGOs:
				taggedGO.SendMessage(
					kReceiveMethodName,
					note,
					SendMessageOptions.DontRequireReceiver
				)
			
		elif scope == Scope.Global:
			GameObject.Find('/').BroadcastMessage(
				kReceiveMethodName,
				note,
				SendMessageOptions.DontRequireReceiver
			)
			
		else:
			assert "unknown ${self.GetType()}.Scope ${scope.ToString()}"
