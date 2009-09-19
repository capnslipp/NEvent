## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
#import System.Reflection
import UnityEngine


[Serializable]
abstract class NEventBase:
	public static final kReceiveMethodName = 'ReceiveNEvent'
	
	
	[Getter(name)]
	final _name as string
	
	messageName as string:
		get:
			return "On${name}"
	
	
	def constructor():
		# figure out the name from the class's name
		typeName as string = self.GetType().Name
		assert typeName.EndsWith('Event'), "Event Type \"${typeName}\"'s name must end with the word 'Event'"
		_name = typeName.Remove( typeName.LastIndexOf('Event') )
	
	
	
	def Send(targets as (GameObject)) as void:
		Send(targets, false)
	
	def Send(targets as (GameObject), global as bool) as void:
		# normal-case: send to the specified targets
		if targets.Length > 0:
			SendToTargets(targets)
			
		# special-case: send globally to all GameObjects
		elif global:
			SendGlobally()
		# invalid-case
		else:
			assert false, "Either targets must be specified or the message must be global, but not neither nor both."
	
	
	private def SendToTargets(targets as (GameObject)) as void:
		for target as GameObject in targets:
			target.SendMessage(
				kReceiveMethodName,
				self,
				SendMessageOptions.DontRequireReceiver
			)
	
	private def SendGlobally() as void:
		GameObject.Find('/').BroadcastMessage(
			kReceiveMethodName,
			self,
			SendMessageOptions.DontRequireReceiver
		)
	
	
	
	# When sub-classing, add any data you like!
