## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import UnityEngine


class NectarEventPort (MonoBehaviour):
	_eventBuffer as (INectarNote) #= array(INectarNote, 0)
	
	
	count as int:
		get:
			return _eventBuffer.Length
	
	
	## flushes out all the old events (clearing them) and starts waiting for new ones
	def Clean() as void:
		_eventBuffer = array(INectarNote, 0)
	
	## flushes out all the old events (returning them) and starts waiting for new ones
	def Flush() as (INectarNote):
		tempEventBuffer = _eventBuffer # copy the array (hopefully)
		Clean()
		return tempEventBuffer
	
	
	## removes and returns the frontmost NectarEvent in the eventBuffer
	def Pop() as INectarNote:
		return null if _eventBuffer.Length == 0
		frontNEvent = _eventBuffer[0]
		_eventBuffer = _eventBuffer[:-1]
		return frontNEvent
	
	## adds a NectarEvent to the back of the eventBuffer
	private def Push(note as INectarNote) as void:
		_eventBuffer += (note,)
	
	
	## grabs function calls (likely Unity SendMessage calls) that match the correct pattern and stuffs them into the event buffer
	def NectarReceive(note as INectarNote) as void:
		Push(note)
