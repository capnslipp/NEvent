## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
import System.Reflection
import UnityEngine


class NEventDispatch (MonoBehaviour):
	## grabs function calls (likely Unity SendMessage calls) that match the correct pattern and re-sends them locally as On… calls
	def ReceiveNEvent(note as NEventBase) as void:
		
		# find out how many public properties note has and package them up into an object array
		noteFields as (FieldInfo) = note.GetType().GetFields(BindingFlags.Public | BindingFlags.Instance)
		if noteFields.Length == 1:
			gameObject.SendMessage(
				note.messageName,
				noteFields[0].GetValue(note),
				SendMessageOptions.DontRequireReceiver
			)
			
		elif noteFields.Length > 1:
			messageArgs as (object) = array(object, 0)
			
			for noteField as FieldInfo in noteFields:
				messageArgs += (noteField.GetValue(note),)
			
			gameObject.SendMessage(
				note.messageName,
				messageArgs,
				SendMessageOptions.DontRequireReceiver
			)
			
		else:
			assert noteFields.Length > 0
