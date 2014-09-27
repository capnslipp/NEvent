/// Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
/// @author	Slippy Douglas
/// @purpose	Provides …


using System;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;


[Serializable]
public class NEventAction
{
	public SerializableDerivedType eventType = new SerializableDerivedType(typeof(NEventBase));
	
	
	string name {
		get {
			return NEventBase.GetName(this.eventType.type);
		}
	}
	
	string messageName {
		get {
			return NEventBase.GetMessageName(this.eventType.type);
		}
	}
	
	
	
	public NEventAction(Type anEventType)
	{
		if (anEventType == null)
			throw new ArgumentNullException("anEventType");
		
		this.eventType.type = anEventType;
	}
	
	public NEventAction(Type anEventType, Scope aScope) :
		this(anEventType)
	{
		this.scope = aScope;
	}
	
	
	
	public enum Scope {
		Local, // sender GameObject
		Children, // sender & children
		Descendents, // sender & descendents
		Parent, // sender & parent
		Ancestors, // sender, parent, upwards
		Specific, // sender & a specific GameObject
		Named, // sender & a named GameObject
		Tagged, // sender & all tagged GameObjects
		Global, // all GameObjects; only use for testing!!!
	}
	
	public Scope scope = Scope.Local;
	
	public GameObject scopeSpecificGO = null;
	public string scopeName = "";
	public string scopeTag = "";
	
	
	
	// @todo: store owner sender
	void Send(GameObject sender) {
		Send(sender, null);
	}
	// @todo: store owner sender
	void Send(GameObject sender, object sendEventArg) {
		Send(sender, new object[]{ sendEventArg });
	}
	// @todo: store owner sender
	void Send(GameObject sender, object[] sendEventArgs)
	{
		if (sender == null)
			throw new ArgumentNullException("sender");
		
		// create the Event
		
		if (this.eventType.type == null)
			throw new ArgumentNullException("eventType.type");
		
		NEventBase sendEvent = Activator.CreateInstance(this.eventType.type) as NEventBase;
		if (!sendEvent.GetType().IsSubclassOf(typeof(NEventBase)))
			throw new InvalidOperationException();
		
		
		// populate the Event's data
		
		FieldInfo[] sendEventFields = sendEvent.GetType().GetFields(BindingFlags.Public | BindingFlags.Instance);
		if (sendEventArgs.Length != sendEventFields.Length)
			throw new InvalidOperationException();
		
		for (int nI = 0; nI < sendEventFields.Length; ++nI) {
			FieldInfo sendEventField = sendEventFields[nI];
			sendEventField.SetValue(sendEvent, sendEventArgs[nI]);
		}
		
		
		// figure out the event's target(s)
		
		List<GameObject> targets = new List<GameObject>() { sender };
		bool global = false;
		
		switch (this.scope)
		{
			case Scope.Local:
				break;
			
			case Scope.Children:
				foreach (Transform childTransform in sender.transform)
					targets.Add(childTransform.gameObject);
				break;
			
			case Scope.Parent:
				targets.Add(sender.transform.parent.gameObject);
				break;
			
			case Scope.Ancestors:
				Transform ancestorRef = sender.transform.parent;
				
				while (ancestorRef != null) {
					targets.Add(ancestorRef.gameObject);
					ancestorRef = ancestorRef.parent;
				}
				break;
			
			case Scope.Specific:
				if (this.scopeSpecificGO == null)
					throw new ArgumentNullException("scopeSpecificGO");
				
				targets.Add(this.scopeSpecificGO);
				break;
			
			case Scope.Named:
				if (String.IsNullOrEmpty(this.scopeName))
					throw new ArgumentException("scopeName");
				
				targets.Add(GameObject.Find(this.scopeName));
				break;
			
			case Scope.Tagged:
				if (String.IsNullOrEmpty(this.scopeTag))
					throw new ArgumentException("scopeTag");
				
				GameObject[] taggedGOs = GameObject.FindGameObjectsWithTag(this.scopeTag);
				targets.AddRange(taggedGOs);
				break;
			
			case Scope.Global:
				targets.Clear();
				global = true;
				break;
			
			default:
				throw new ArgumentException("unknown "+this.GetType()+".Scope "+this.scope.ToString(), "scope");
		}
		
		
		// send the info off to the Plug (sender)
		
		// @todo: cache the NEventPlug ref
		NEventPlug eventPlug = sender.GetComponent<NEventPlug>();
		
		// if an event plug is available, use it
		if (eventPlug != null)
			eventPlug.PushNEvent(sendEvent, targets.ToArray(), global);
		// otherwise, just send the event immediately
		else
			sendEvent.Send(targets.ToArray(), global);
	}
}
