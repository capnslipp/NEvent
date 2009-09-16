## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
import System.Reflection
import UnityEngine


class NReactionDock (MonoBehaviour):
	public reactions as (NReactionBase) = array(NReactionBase, 0)
	
	
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
