## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
#import System.Reflection
import UnityEngine


class NEventPlug (MonoBehaviour):
	struct Envelope:
		note as NEventBase
		targets as (GameObject)
		global as bool
	
	_eventBuffer as (Envelope) = array(Envelope, 0)
	
	
	count as int:
		get:
			return _eventBuffer.Length
	
	
	def Update() as void:
		Send() if enabled
	
	
	def PushNEvent(note as NEventBase, targets as (GameObject)) as void:
		PushNEvent(note, targets, false)
	
	def PushNEvent(note as NEventBase, targets as (GameObject), global as bool) as void:
		_eventBuffer += (Envelope(
			note: note,
			targets: targets,
			global: global
		),)
	
	
	def SendEvents() as void:
		assert not enabled, "This NEventPlug auto-sends (since it is enabled), direct SendEvents() calls are not allowed."
		Send()
	
	
	## sends out all the events (removing them from the buffer) and starts waiting for new ones
	private def Send() as void:
		eventsToSend = Flush()
		
		for eventEnvelope as Envelope in eventsToSend:
			eventEnvelope.note.Send(eventEnvelope.targets, eventEnvelope.global)
	
	
	## clears out all the old events (returning nothing)
	private def Clean() as void:
		_eventBuffer = array(Envelope, 0)
	
	## flushes out all the old events (returning them)
	private def Flush() as (Envelope):
		tempEventBuffer = _eventBuffer # copy the array (hopefully)
		Clean()
		return tempEventBuffer
