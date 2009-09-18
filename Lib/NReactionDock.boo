## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
import System.Collections
import System.Reflection
import UnityEngine


class NReactionDock (MonoBehaviour):
	public reactions as (NReactionBase) = array(NReactionBase, 0)
	
	
	def Awake():
		for reaction in reactions:
			reaction.owner = gameObject
	
	
	def HasReaction(reactionType as Type) as bool:
		for reaction as NReactionBase in reactions:
			if reaction.GetType() == reactionType:
				return true
		return false
	
	def GetReaction(reactionType as Type) as NReactionBase:
		for reaction as NReactionBase in reactions:
			if reaction.GetType() == reactionType:
				return reaction
		return null
	
	def AddReaction(reactionType as Type) as NReactionBase:
		assert reactionType.IsSubclassOf(NReactionBase)
		AddReaction( ScriptableObject.CreateInstance(reactionType.ToString()) )
	
	def AddReaction(reactionToAdd as NReactionBase) as NReactionBase:
		reactionType as Type = reactionToAdd.GetType()
		assert not HasReaction(reactionType)
		reactionToAdd.owner = gameObject
		reactions += (reactionToAdd,)
	
	
	# IEnumerable
	
	def GetEnumerator() as IEnumerator:
		return Enumerator(reactions);
	
	class Enumerator (IEnumerator):
		_reactions as (NReactionBase)
		
		# Enumerators are positioned before the first element until the first MoveNext() call.
		_position as int = -1
		
		def constructor(reactionArray as (NReactionBase)):
			_reactions = reactionArray
		
		def MoveNext() as bool:
			++_position
			return _position < _reactions.Length
		
		def Reset() as void:
			_position = -1
		
		Current as object:
			get:
				try:
					return _reactions[_position];
				except IndexOutOfRangeException:
					raise InvalidOperationException()
	
	
	# NEvent handling
	
	## grabs function calls (likely Unity SendMessage calls) that match the correct pattern and re-sends them to all contained reactions as On… calls
	def ReceiveNEvent(note as NEventBase) as void:
		# find out how many public properties note has and package them up into an object array
		noteFields as (FieldInfo) = note.GetType().GetFields(BindingFlags.Public | BindingFlags.Instance)
		reactionMethodInfo as MethodInfo
		
		if noteFields.Length == 1: 
			for reaction as NReactionBase in reactions:
				reactionMethodInfo = reaction.GetType().GetMethod( note.messageName )
				assert reactionMethodInfo is not null
				reactionMethodInfo.Invoke(reaction, (noteFields[0].GetValue(note),))
			
		elif noteFields.Length > 1:
			messageArgs as (object) = array(object, 0)
			
			for noteField as FieldInfo in noteFields:
				messageArgs += (noteField.GetValue(note),)
			
			for reaction as NReactionBase in reactions:
				reactionMethodInfo = reaction.GetType().GetMethod( note.messageName )
				assert reactionMethodInfo is not null
				reactionMethodInfo.Invoke(reaction, messageArgs)
			
		else:
			assert noteFields.Length == 0
			
			for reaction as NReactionBase in reactions:
				reactionMethodInfo = reaction.GetType().GetMethod( note.messageName )
				assert reactionMethodInfo is not null
				reactionMethodInfo.Invoke(reaction, null)
