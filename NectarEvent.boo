## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


#import System.Reflection
import UnityEngine


class NectarEvent:
	[Getter(name)]
	_name as string
	
	messageName as string:
		get:
			return "On${_name}"
	
	
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
	
	
	def constructor():
		typeName as string = self.GetType().Name
		assert typeName.EndsWith('Event')
		_name = typeName.Remove( typeName.LastIndexOf('Event') )
	
	
	def Send(sender as GameObject):
		if scope == Scope.Local:
			sender.SendMessage(messageName, self, SendMessageOptions.DontRequireReceiver)
			
		elif scope == Scope.Children:
			sender.BroadcastMessage(messageName, self, SendMessageOptions.DontRequireReceiver)
			
		elif scope == Scope.Parent:
			sender.SendMessage(messageName, self, SendMessageOptions.DontRequireReceiver)
			sender.transform.parent.SendMessage(messageName, self, SendMessageOptions.DontRequireReceiver)
			
		elif scope == Scope.Ancestors:
			sender.transform.SendMessageUpwards(messageName, self, SendMessageOptions.DontRequireReceiver)
			
		elif scope == Scope.Specific:
			sender.SendMessage(messageName, self, SendMessageOptions.DontRequireReceiver)
			scopeSpecificGO.SendMessage(messageName, self, SendMessageOptions.DontRequireReceiver)
			
		elif scope == Scope.Named:
			sender.SendMessage(messageName, self, SendMessageOptions.DontRequireReceiver)
			GameObject.Find(scopeName).SendMessage(messageName, self, SendMessageOptions.DontRequireReceiver)
			
		elif scope == Scope.Tagged:
			sender.SendMessage(messageName, self, SendMessageOptions.DontRequireReceiver)
			
			taggedGOs = GameObject.FindGameObjectsWithTag(scopeTag)
			for taggedGO in taggedGOs:
				taggedGO.SendMessage(messageName, self, SendMessageOptions.DontRequireReceiver)
			
		elif scope == Scope.Global:
			GameObject.Find('/').BroadcastMessage(messageName, self, SendMessageOptions.DontRequireReceiver)
			
		else:
			assert "unknown ${self.GetType()}.Scope ${scope.ToString()}"
