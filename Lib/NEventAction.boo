## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
import System.Reflection
import UnityEngine


[Serializable]
class NEventAction:
	# hand-edit at your own risk!
	public eventTypeName as string
	
	eventType as Type:
		get:
			return null if String.IsNullOrEmpty(eventTypeName)
			type as Type = Type.GetType(eventTypeName)
			assert type.IsSubclassOf(NEventBase), "${type} must be derived from NEventBase"
			return type
		set:
			assert value.IsSubclassOf(NEventBase), "${value} must be derived from NEventBase"
			eventTypeName = value.Name
	
	
	name as string:
		get:
			return NEventBase.GetName(eventType)
	
	messageName as string:
		get:
			return NEventBase.GetMessageName(eventType)
	
	
	
	def constructor(anEventType as Type):
		assert anEventType is not null
		eventTypeName = anEventType.Name
	
	
	
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
	
	public scope as Scope = Scope.Local
	
	public scopeSpecificGO as GameObject
	public scopeName as string = ''
	public scopeTag as string = ''
	
	
	
	# @todo: store sender as owner
	def Send(sender as GameObject) as void:
		Send(sender, null)
	
	# @todo: store sender as owner
	def Send(sender as GameObject, sendEventArg as object) as void:
		Send(sender, (sendEventArg,))
	
	# @todo: store sender as owner
	def Send(sender as GameObject, sendEventArgs as (object)) as void:
		assert sender is not null
		
		# create the Event
		
		sendEventType as Type = eventType()
		assert sendEventType is not null
		sendEvent as NEventBase = sendEventType()
		assert sendEvent.GetType().IsSubclassOf(NEventBase)
		
		
		# populate the Event's data
		
		sendEventFields as (FieldInfo) = sendEvent.GetType().GetFields(BindingFlags.Public | BindingFlags.Instance)
		assert sendEventArgs.Length == sendEventFields.Length
		
		for nI in range(0, sendEventFields.Length):
			sendEventField as FieldInfo = sendEventFields[nI]
			sendEventField.SetValue(sendEvent, sendEventArgs[nI])
		
		
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
			eventPlug.PushNEvent(sendEvent, targets, global)
		# otherwise, just send the event immediately
		else:
			sendEvent.Send(targets, global)
