﻿## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import UnityEngine


class NEventSocket (MonoBehaviour):
	_eventBuffer as (NEventBase) = array(NEventBase, 0)
	
	
	count as int:
		get:
			return _eventBuffer.Length
	
	
	## clears out all the old events (returning nothing) and starts waiting for new ones
	def Clean() as void:
		_eventBuffer = array(NEventBase, 0)
	
	## flushes out all the old events (returning them) and starts waiting for new ones
	def Flush() as (NEventBase):
		tempEventBuffer = _eventBuffer # copy the array (hopefully)
		Clean()
		return tempEventBuffer
	
	
	## removes and returns the frontmost NEvent in the eventBuffer
	def Pop() as NEventBase:
		return null if _eventBuffer.Length == 0
		frontNEvent = _eventBuffer[0]
		_eventBuffer = _eventBuffer[:-1]
		return frontNEvent
	
	## adds a NEvent to the back of the eventBuffer
	private def Push(note as NEventBase) as void:
		_eventBuffer += (note,)
	
	
	## grabs function calls (likely Unity SendMessage calls) that match the correct pattern and stuffs them into the event buffer
	def ReceiveNEvent(note as NEventBase) as void:
		Push(note)
