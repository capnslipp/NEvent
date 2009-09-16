## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
import System.Reflection
import UnityEngine


class NEventAction:
	static final kReceiveMethodName = 'ReceiveNEvent'
	
	
	noteType as Type
	
	
	name as string:
		get:
			# @todo: bad, bad, bad; must find a cleaner way to do this!
			return (noteType() as NEventBase).name
	
	messageName as string:
		get:
			# @todo: bad, bad, bad; must find a cleaner way to do this!
			return (noteType() as NEventBase).messageName
	
	
	def constructor(noteType as string):
		noteType = Type.GetType(noteType)
		assert noteType.IsSubclassOf(NEventBase)
	
	def constructor(noteType as Type):
		noteType = noteType
		assert noteType.IsSubclassOf(NEventBase)
		
	
	
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
		Send(sender, null)
	
	def Send(sender as GameObject, noteArg as object):
		Send(sender, (noteArg,))
	
	def Send(sender as GameObject, noteArgs as (object)):
		note = ScriptableObject.CreateInstance(noteType.ToString())
		assert note.GetType().IsSubclassOf(NEventBase)
		
		
		noteFields as (FieldInfo) = note.GetType().GetFields(BindingFlags.Public | BindingFlags.Instance)
		assert noteArgs.Length == noteFields.Length
		
		for nI in range(0, noteFields.Length - 1):
			noteField as FieldInfo = noteFields[nI]
			noteField.SetValue(note, noteArgs[nI])
		
		
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
