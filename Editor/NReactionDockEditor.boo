## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
#import System.Reflection
import UnityEditor
#import UnityEngine


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
				EditableGUILayoutForValue(target.reactions[listI])
				EditorGUILayout.EndHorizontal()
	
	
	#private def viewableGUILayoutForValue(fieldValue as NReactionBase) as void:
	#	GUILayout.Label( fieldValue.GetType().ToString() )
	
	
	private def EditableGUILayoutForValue(fieldValue as NReactionBase) as void:
		SubTypeField(fieldValue.GetType(), typeof(NReactionBase))
	
	
	private def SubTypeField(selectedType as Type, baseType as Type) as Type:
		EditorGUILayout.Popup(
			0,
			('None',) + SubTypeNames(typeof(NReactionBase))
		)
	
	
	private def SubTypeNames(baseType as Type) as (string):
		typeNames as (string) = array(string, 0)
		for type as Type in FindDerivedTypes(NReactionBase):
			typeNames += (type.Name,)
		return typeNames
	
	
	private def FindDerivedTypes(baseType as Type) as (Type):
		return baseType.Module.FindTypes(DerivedTypeFilter, baseType)
	
	private def DerivedTypeFilter(m as Type, filterCriteria as object) as bool:
		return m.IsSubclassOf(filterCriteria as Type)