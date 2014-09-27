/// Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
/// @author	Slippy Douglas
/// @purpose	Provides …


using System;
//using System.Reflection;
using UnityEngine;


abstract public class NEventBase
{
	public static readonly string kReceiveMethodName = "ReceiveNEvent";
	
	
	
	static public string GetName(Type eventType)
	{
		string typeName = eventType.Name;
		if (!typeName.EndsWith("Event"))
			throw new ArgumentException("Event Type \""+typeName+"\"'s name must end with the word 'Event'", "typeName");
		
		return typeName.Remove(
			typeName.LastIndexOf("Event")
		);
	}
	
	static public string GetMessageName(Type eventType)
	{
		return "On"+GetName(eventType);
	}
	
	
	readonly protected string _name;
	public string name {
		get { return _name; }
	}
	
	readonly protected string _messageName;
	public string messageName {
		get { return _messageName; }
	}
	
	
	
	public NEventBase()
	{
		if (this.GetType() == typeof(NEventBase))
			throw new InvalidOperationException(this.GetType().FullName+" cannot be instantiated directly.");
		
		// figure out the name from the class's name
		_name = GetName(this.GetType());
		_messageName = GetMessageName(this.GetType());
	}
	
	
	
	public void Send(GameObject[] targets) {
		Send(targets, false);
	}
	public void Send(GameObject[] targets, bool global)
	{
		// normal-case: send to the specified targets
		if (targets.Length > 0)
			SendToTargets(targets);
		// special-case: send globally to all GameObjects
		else if (global)
			SendGlobally();
		// invalid-case
		else
			throw new InvalidOperationException("Either targets must be specified or the message must be global, but not neither nor both.");
	}
	
	
	private void SendToTargets(GameObject[] targets)
	{
		foreach (GameObject target in targets) {
			target.SendMessage(
				kReceiveMethodName,
				this,
				SendMessageOptions.DontRequireReceiver
			);
		}
	}
	
	private void SendGlobally()
	{
		GameObject.Find("/").BroadcastMessage(
			kReceiveMethodName,
			this,
			SendMessageOptions.DontRequireReceiver
		);
	}
	
	
	
	// When sub-classing, add any data you like!
}
