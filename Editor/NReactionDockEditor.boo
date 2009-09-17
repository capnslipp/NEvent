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
			origLength as int = target.reactions.Length
			newLength as int = EditorGUILayout.IntField(origLength)
			if newLength > origLength:
				target.reactions += array(NReactionBase, newLength - origLength)
			elif origLength > newLength:
				target.reactions = (target.reactions as (NReactionBase))[:newLength]
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
