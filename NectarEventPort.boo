## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import UnityEngine


class NectarEventPort (MonoBehaviour, IQuackFu):
	_eventBuffer as (NectarEvent) = array(NectarEvent, 0)
	
	
	count as int:
		get:
			return _eventBuffer.Length
	
	
	## flushes out all the old events (clearing them) and starts waiting for new ones
	def Clean() as void:
		_eventBuffer = array(NectarEvent, 0)
	
	## flushes out all the old events (returning them) and starts waiting for new ones
	def Flush() as (NectarEvent):
		tempEventBuffer = _eventBuffer # copy the array (hopefully)
		Clean()
		return tempEventBuffer
	
	
	## removes and returns the frontmost NectarEvent in the eventBuffer
	def Pop() as NectarEvent:
		return null if _eventBuffer.Length == 0
		frontNEvent = _eventBuffer[0]
		_eventBuffer = _eventBuffer[:-1]
		return frontNEvent
	
	## adds a NectarEvent to the back of the eventBuffer
	private def Push(nEvent as NectarEvent) as void:
		_eventBuffer += (nEvent,)
	
	
	## grabs function calls (likely Unity SendMessage calls) that match the correct pattern and stuffs them into the event buffer
	def QuackInvoke(name as string, args as (object)) as object:
		return unless args.Length > 0 and args[0].GetType().IsSubclassOf(NectarEvent)
		return unless name.StartsWith('On')
		Push(args[0])
	
	
	## required by IQuackFu, but unused
	def QuackGet(name as string, params as (object)) as object:
		raise System.InvalidOperationException("Member ${name} not found in class ${self.GetType()}")
	
	## required by IQuackFu, but unused
	def QuackSet(name as string, params as (object), value as object) as object:
		raise System.InvalidOperationException("Member ${name} not found in class ${self.GetType()}")