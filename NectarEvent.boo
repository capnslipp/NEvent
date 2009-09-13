## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
import UnityEngine


final class NectarEvent:
	static final kReceiveMethodName = 'NectarReceive'
	
	
	public data as INectarNote
	
	
	name as string:
		get:
			return data.name
	
	messageName as string:
		get:
			return "On${name}"
	
	
	def constructor(dataNote as INectarNote):
		data = dataNote
		
		dataTypeName as string = data.GetType().Name
		assert dataTypeName.EndsWith('Note')
		assert data.name == dataTypeName.Remove( dataTypeName.LastIndexOf('Note') )
	
	
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
			sender.SendMessage(
				kReceiveMethodName,
				data,
				SendMessageOptions.DontRequireReceiver
			)
			
		elif scope == Scope.Children:
			sender.BroadcastMessage(
				kReceiveMethodName,
				data,
				SendMessageOptions.DontRequireReceiver
			)
			
		elif scope == Scope.Parent:
			sender.SendMessage(
				kReceiveMethodName,
				data,
				SendMessageOptions.DontRequireReceiver
			)
			sender.transform.parent.SendMessage(
				kReceiveMethodName,
				data,
				SendMessageOptions.DontRequireReceiver
			)
			
		elif scope == Scope.Ancestors:
			sender.transform.SendMessageUpwards(
				kReceiveMethodName,
				data,
				SendMessageOptions.DontRequireReceiver
			)
			
		elif scope == Scope.Specific:
			sender.SendMessage(
				kReceiveMethodName,
				data,
				SendMessageOptions.DontRequireReceiver
			)
			scopeSpecificGO.SendMessage(
				kReceiveMethodName,
				data,
				SendMessageOptions.DontRequireReceiver
			)
			
		elif scope == Scope.Named:
			sender.SendMessage(
				kReceiveMethodName,
				data,
				SendMessageOptions.DontRequireReceiver
			)
			GameObject.Find(scopeName).SendMessage(
				kReceiveMethodName,
				data,
				SendMessageOptions.DontRequireReceiver
			)
			
		elif scope == Scope.Tagged:
			sender.SendMessage(
				kReceiveMethodName,
				data,
				SendMessageOptions.DontRequireReceiver
			)
			
			taggedGOs = GameObject.FindGameObjectsWithTag(scopeTag)
			for taggedGO in taggedGOs:
				taggedGO.SendMessage(
					kReceiveMethodName,
					data,
					SendMessageOptions.DontRequireReceiver
				)
			
		elif scope == Scope.Global:
			GameObject.Find('/').BroadcastMessage(
				kReceiveMethodName,
				data,
				SendMessageOptions.DontRequireReceiver
			)
			
		else:
			assert "unknown ${self.GetType()}.Scope ${scope.ToString()}"
