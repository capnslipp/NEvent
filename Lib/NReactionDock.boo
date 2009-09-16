## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
import System.Collections
import System.Reflection
import UnityEngine


class NReactionDock (MonoBehaviour):
	_reactions as Hash = {}
	
	def HasReaction(reactionType as Type) as bool:
		return _reactions.ContainsKey(reactionType)
	
	def GetReaction(reactionType as Type) as NReactionBase:
		return _reactions[reactionType]
	
	def AddReaction(reactionType as Type) as NReactionBase:
		assert reactionType.IsSubclassOf(NReactionBase)
		AddReaction( ScriptableObject.CreateInstance(reactionType.ToString()) )
	
	def AddReaction(reactionToAdd as NReactionBase) as NReactionBase:
		reactionType as Type = reactionToAdd.GetType()
		assert not HasReaction(reactionType)
		reactionToAdd.owner = gameObject
		_reactions[reactionType] = reactionToAdd
	
	
	# IEnumerable
	
	def GetEnumerator() as IEnumerator:
		return Enumerator(_reactions.Values);
	
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
		reaction as NReactionBase
		reactionMethodInfo as MethodInfo
		
		if noteFields.Length == 1: 
			for reactionEntry as DictionaryEntry in _reactions:
				reaction = reactionEntry.Value
				reactionMethodInfo = reaction.GetType().GetMethod( note.messageName )
				assert reactionMethodInfo is not null
				reactionMethodInfo.Invoke(reaction, (noteFields[0].GetValue(note),))
			
		elif noteFields.Length > 1:
			messageArgs as (object) = array(object, 0)
			
			for noteField as FieldInfo in noteFields:
				messageArgs += (noteField.GetValue(note),)
			
			for reactionEntry as DictionaryEntry in _reactions:
				reaction = reactionEntry.Value
				reactionMethodInfo = reaction.GetType().GetMethod( note.messageName )
				assert reactionMethodInfo is not null
				reactionMethodInfo.Invoke(reaction, messageArgs)
			
		else:
			assert noteFields.Length == 0
			
			for reactionEntry as DictionaryEntry in _reactions:
				reaction = reactionEntry.Value
				reactionMethodInfo = reaction.GetType().GetMethod( note.messageName )
				assert reactionMethodInfo is not null
				reactionMethodInfo.Invoke(reaction, null)
