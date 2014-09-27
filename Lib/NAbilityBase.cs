// Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
// @author	Slippy Douglas
// @purpose	Provides …


using System;
//using System.Reflection;
using UnityEngine;


abstract public class NAbilityBase : ScriptableObject
{
	protected readonly string _abilityName;
	public string abilityName {
		get { return _abilityName; }
	}
	
	
	// allows derived classes access to the handy GameObject and Component accessors
	protected GameObject _abilityOwner;
	public GameObject abilityOwner {
		set {
			if (value == null)
				throw new ArgumentNullException("value");
			
			_abilityOwner = value;
		}
	}
	
	
	public NAbilityBase()
	{
		if (this.GetType() == typeof(NAbilityBase))
			throw new InvalidOperationException(this.GetType().FullName+" cannot be instantiated directly.");
		
		// figure out the name from the class's name
		string typeName = this.GetType().Name;
		if (!typeName.EndsWith("Ability"))
			throw new InvalidOperationException("");
		
		_abilityName = typeName.Remove(
			typeName.LastIndexOf("Ability")
		);
	}
	
	
	void OnEnable() {
		Awake();
	}
	
	
	
	// convenience methods
	
	virtual public void Awake() {}
	
	
	
	// convenience properties
	
	public GameObject gameObject {
		get {
			if (_abilityOwner == null)
				throw new ArgumentNullException("_abilityOwner");
			
			return _abilityOwner;
		}
	}
	
	
	
	// When sub-classing, add any data you like!
}
