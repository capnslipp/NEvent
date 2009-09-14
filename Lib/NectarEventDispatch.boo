## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import UnityEngine


class NEventDispatch (MonoBehaviour):
	## grabs function calls (likely Unity SendMessage calls) that match the correct pattern and re-sends them locally as On… calls
	def ReceiveNEvent(note as NEventBase) as void:
		messageArgs as (object) = array(object, 0)
		
		# @todo: find out how many public properties note has and package them up into an object array
		
		gameObject.SendMessage(
			note.messageName,
			messageArgs,
			SendMessageOptions.DontRequireReceiver
		)
