/// Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
/// @author	Slippy Douglas
/// @purpose	Provides …


using System;
using System.Collections;
using System.Collections.Generic;
//using System.Reflection;
using UnityEngine;


[RequireComponent(typeof(NEventPlug))]
public class NAbilityDock : MonoBehaviour, IEnumerable
{
	public List<NAbilityBase> abilities = new List<NAbilityBase>();
	
	
	void Awake()
	{
		foreach (NAbilityBase ability in this.abilities)
			ability.abilityOwner = this.gameObject;
	}
	
	
	bool HasAbility(Type abilityType)
	{
		foreach (NAbilityBase ability in this.abilities) {
			if (ability.GetType() == abilityType)
				return true;
		}
		return false;
	}
	
	NAbilityBase GetAbility(Type abilityType)
	{
		foreach (NAbilityBase ability in this.abilities) {
			if (ability.GetType() == abilityType)
				return ability;
		}
		return null;
	}
	
	NAbilityBase AddAbility(Type abilityType)
	{
		if (!abilityType.IsSubclassOf(typeof(NAbilityBase)))
			throw new ArgumentException("abilityType");
		
		return AddAbility(
			ScriptableObject.CreateInstance(abilityType.ToString()) as NAbilityBase
		);
	}
	
	NAbilityBase AddAbility(NAbilityBase abilityToAdd)
	{
		Type abilityType = abilityToAdd.GetType();
		if (HasAbility(abilityType))
			throw new ArgumentException("abilityType");
		
		abilityToAdd.abilityOwner = this.gameObject;
		this.abilities.Add(abilityToAdd);
		return abilityToAdd;
	}
	
	
	// IEnumerable
	
	public IEnumerator GetEnumerator()
	{
		return new Enumerator(this.abilities);
	}
	
	class Enumerator : IEnumerator
	{
		protected List<NAbilityBase> _abilities;
		
		// Enumerators are positioned before the first element until the first MoveNext() call.
		protected int _position = -1;
		
		public Enumerator(List<NAbilityBase> abilityList)
		{
			_abilities = abilityList;
		}
		
		public bool MoveNext()
		{
			++_position;
			return (_position < _abilities.Count);
		}
		
		public void Reset()
		{
			_position = -1;
		}
		
		public object Current {
			get {
				try {
					return _abilities[_position];
				}
				catch (IndexOutOfRangeException) {
					throw new InvalidOperationException();
				}
			}
		}
	}
	
}
