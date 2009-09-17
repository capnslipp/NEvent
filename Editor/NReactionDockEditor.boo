## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
#import System.Reflection
import UnityEditor
import UnityEngine


[CustomEditor(NReactionDock)]
class NReactionDockEditor (Editor):
	_listIsExpanded as bool = true
	
	
	def OnInspectorGUI():
		_listIsExpanded = EditorGUILayout.Foldout(_listIsExpanded, 'Reactions')
		if _listIsExpanded:
			EditorGUILayout.BeginHorizontal()
			EditorGUILayout.PrefixLabel('Size')
			
			targetReactionsList as List = List(target.reactions as (NReactionBase))
			origLength as int = targetReactionsList.Count
			newLength as int = EditorGUILayout.IntField(origLength)
			
			# if the requested size is longer, add null elements to the end
			if newLength > origLength:
				for newI as int in range(newLength - origLength):
					targetReactionsList.Add(null)
			# if the requested size is shorter, remove elements from the end
			elif origLength > newLength:
				for oldI as int in range(origLength - newLength):
					targetReactionsList.Pop()
			
			target.reactions = array(NReactionBase, targetReactionsList)
			
			EditorGUILayout.EndHorizontal()
			
			
			for listI as int in range(target.reactions.Length):
				EditorGUILayout.BeginHorizontal()
				EditorGUILayout.PrefixLabel("Element ${listI}")
				
				target.reactions[listI] = EditableGUILayoutForValue(target.reactions[listI])
				
				EditorGUILayout.EndHorizontal()
	
	
	#private def viewableGUILayoutForValue(fieldValue as NReactionBase) as void:
	#	GUILayout.Label( fieldValue.GetType().ToString() )
	
	
	private def EditableGUILayoutForValue(fieldValue as NReactionBase) as NReactionBase:
		fieldValueType as Type
		fieldValueType = fieldValue.GetType() if fieldValue is not null
		
		resultType = NEditorGUILayout.DerivedTypeField(fieldValueType, typeof(NReactionBase))
		
		if fieldValueType == resultType:
			return fieldValue
		else:
			if resultType is null:
				return null
			else:
				return ScriptableObject().CreateInstance(resultType.ToString())
