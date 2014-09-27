/// Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
/// @author	Slippy Douglas
/// @purpose	Provides …


using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;


public class NReactionDock : MonoBehaviour
{
	public List<NReactionBase> reactions = new List<NReactionBase>();
	
	
	void Awake()
	{
		foreach (NReactionBase reaction in this.reactions)
			reaction.reactionOwner = this.gameObject;
	}
	
	
	bool HasReaction(Type reactionType)
	{
		foreach (NReactionBase reaction in this.reactions) {
			if (reaction.GetType() == reactionType)
				return true;
		}
		return false;
	}
	
	NReactionBase GetReaction(Type reactionType)
	{
		foreach (NReactionBase reaction in this.reactions) {
			if (reaction.GetType() == reactionType)
				return reaction;
		}
		return null;
	}
	
	NReactionBase AddReaction(Type reactionType)
	{
		if (!reactionType.IsSubclassOf(typeof(NReactionBase)))
			throw new ArgumentException("reactionType");
		
		return AddReaction(
			ScriptableObject.CreateInstance(reactionType.ToString()) as NReactionBase
		);
	}
	NReactionBase AddReaction(NReactionBase reactionToAdd)
	{
		Type reactionType = reactionToAdd.GetType();
		if (HasReaction(reactionType))
			throw new ArgumentException("reactionType");
		
		reactionToAdd.reactionOwner = this.gameObject;
		this.reactions.Add(reactionToAdd);
		return reactionToAdd;
	}
	
	
	// IEnumerable
	
	IEnumerator GetEnumerator()
	{
		return new Enumerator(this.reactions);
	}
	
	class Enumerator : IEnumerator
	{
		List<NReactionBase> _reactions;
		
		// Enumerators are positioned before the first element until the first MoveNext() call.
		int _position = -1;
		
		public Enumerator(List<NReactionBase> reactionArray)
		{
			_reactions = reactionArray;
		}
		
		public bool MoveNext()
		{
			++_position;
			return (_position < _reactions.Count);
		}
		
		public void Reset()
		{
			_position = -1;
		}
		
		public object Current {
			get {
				try {
					return _reactions[_position];
				}
				catch (IndexOutOfRangeException) {
					throw new InvalidOperationException();
				}
			}
		}
	}
	
	
	// NEvent handling
	
	/// grabs function calls (likely Unity SendMessage calls) that match the correct pattern and re-sends them to all contained On reactions… calls
	void ReceiveNEvent(NEventBase note)
	{
		// find out how many public properties note has and package them up into an object array
		FieldInfo[] noteFields = note.GetType().GetFields(BindingFlags.Public | BindingFlags.Instance);
		MethodInfo reactionMethodInfo;
		
		if (noteFields.Length == 1) {
			foreach (NReactionBase reaction in reactions) {
				reactionMethodInfo = reaction.GetType().GetMethod( note.messageName );
				if (reactionMethodInfo == null)
					throw new ArgumentNullException("reactionMethodInfo");
				
				reactionMethodInfo.Invoke(reaction, new object[]{ noteFields[0].GetValue(note) });
			}
		}
		else if (noteFields.Length > 1) {
			List<object> messageArgs = new List<object>();
			
			foreach (FieldInfo noteField in noteFields)
				messageArgs.Add(noteField.GetValue(note));
			
			foreach (NReactionBase reaction in reactions) {
				reactionMethodInfo = reaction.GetType().GetMethod( note.messageName );
				if (reactionMethodInfo == null)
					throw new ArgumentNullException("reactionMethodInfo");
				
				reactionMethodInfo.Invoke(reaction, messageArgs.ToArray());
			}
		}
		else {
			if (noteFields.Length != 0)
				throw new ArgumentException("noteFields");
			
			foreach (NReactionBase reaction in reactions) {
				reactionMethodInfo = reaction.GetType().GetMethod( note.messageName );
				if (reactionMethodInfo == null)
					throw new ArgumentNullException("reactionMethodInfo");
				
				reactionMethodInfo.Invoke(reaction, null);
			}
		}
	}
}
