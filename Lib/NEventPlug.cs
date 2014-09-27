/// Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
/// @author	Slippy Douglas
/// @purpose	Provides …


using System;
using System.Collections.Generic;
//using System.Reflection;
using UnityEngine;


public class NEventPlug : MonoBehaviour
{
	protected struct Envelope
	{
		public NEventBase note;
		public GameObject[] targets;
		public bool global;
	}
	
	protected List<Envelope> _eventBuffer = new List<Envelope>();
	
	
	public int count {
		get {
			return _eventBuffer.Count;
		}
	}
	
	
	void Update()
	{
		if (this.enabled)
			Send();
	}
	
	
	public void PushNEvent(NEventBase note, GameObject[] targets) {
		PushNEvent(note, targets, false);
	}
	public void PushNEvent(NEventBase note, GameObject[] targets, bool global)
	{
		_eventBuffer.Add(new Envelope {
			note = note,
			targets = targets,
			global = global
		});
	}
	
	
	void SendEvents()
	{
		if (this.enabled)
			throw new InvalidOperationException("This NEventPlug auto-sends (since it is enabled), direct SendEvents() calls are not allowed.");
		
		Send();
	}
	
	
	/// sends out all the events (removing them from the buffer) and starts waiting for new ones
	private void Send()
	{
		Envelope[] eventsToSend = Flush();
		
		foreach (Envelope eventEnvelope in eventsToSend)
			eventEnvelope.note.Send(eventEnvelope.targets, eventEnvelope.global);
	}
	
	
	/// clears out all the old events (returning nothing)
	private void Clean()
	{
		_eventBuffer.Clear();
	}
	
	// flushes out all the old events (returning them)
	private Envelope[] Flush()
	{
		Envelope[] tempEventBuffer = _eventBuffer.ToArray(); // copy the array
		Clean();
		return tempEventBuffer;
	}
}
