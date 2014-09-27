/// Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
/// @author	Slippy Douglas
/// @purpose	Provides …


using System;
using System.Reflection;
using UnityEngine;


abstract public class NReactionBase : ScriptableObject
{
	readonly protected string _reactionName;
	public string reactionName {
		get { return _reactionName; }
	}
	
	readonly protected string _eventName;
	public string eventName {
		get { return _eventName; }
	}
	
	
	// allows derived classes access to the handy GameObject and Component accessors
	protected GameObject _reactionOwner;
	public GameObject reactionOwner {
		set {
			if (value == null)
				throw new ArgumentNullException("value");
			
			_reactionOwner = value;
		}
	}
	
	
	public NReactionBase()
	{
		// figure out the name from the class's name
		string typeName = this.GetType().Name;
		
		if (this.GetType() == typeof(NReactionBase))
			throw new InvalidOperationException(this.GetType().FullName+" cannot be instantiated directly.");
		
		int onCharIndex = typeName.LastIndexOf("On");
		if (onCharIndex == -1)
			throw new ArgumentException("Reaction must have 'On' in their class name.", "typeName");
		
		_reactionName = typeName.Substring(0, onCharIndex);
		if (string.IsNullOrEmpty(_reactionName))
			throw new InvalidOperationException();
		
		_eventName = typeName.Substring(onCharIndex + 2);
		if (string.IsNullOrEmpty(_eventName))
			throw new InvalidOperationException();
		
		MethodInfo[] methods = this.GetType().GetMethods(BindingFlags.Public | BindingFlags.Instance);
		bool methodExistsForEvent = false;
		foreach (MethodInfo methodInfo in methods) {
			if (methodInfo.Name == ("On"+_eventName)) {
				methodExistsForEvent = true;
				break;
			}
		}
		if (!methodExistsForEvent)
			throw new InvalidOperationException("Reaction '"+typeName+"' must have an 'On"+_eventName+"' method.");
	}
	
	
	public GameObject gameObject {
		get {
			if (_reactionOwner == null)
				throw new ArgumentNullException("_reactionOwner");
			
			return _reactionOwner;
		}
	}
}
