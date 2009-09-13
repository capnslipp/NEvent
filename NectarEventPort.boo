## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import UnityEngine


class NectarEventPort (MonoBehaviour):
	_eventBuffer as (NectarNoteBase) #= array(NectarNoteBase, 0)
	
	
	count as int:
		get:
			return _eventBuffer.Length
	
	
	## flushes out all the old events (clearing them) and starts waiting for new ones
	def Clean() as void:
		_eventBuffer = array(NectarNoteBase, 0)
	
	## flushes out all the old events (returning them) and starts waiting for new ones
	def Flush() as (NectarNoteBase):
		tempEventBuffer = _eventBuffer # copy the array (hopefully)
		Clean()
		return tempEventBuffer
	
	
	## removes and returns the frontmost NectarEvent in the eventBuffer
	def Pop() as NectarNoteBase:
		return null if _eventBuffer.Length == 0
		frontNEvent = _eventBuffer[0]
		_eventBuffer = _eventBuffer[:-1]
		return frontNEvent
	
	## adds a NectarEvent to the back of the eventBuffer
	private def Push(note as NectarNoteBase) as void:
		_eventBuffer += (note,)
	
	
	## grabs function calls (likely Unity SendMessage calls) that match the correct pattern and stuffs them into the event buffer
	def NectarReceive(note as NectarNoteBase) as void:
		Push(note)
