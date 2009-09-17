## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
import System.Reflection
import UnityEditor
#import UnityEngine


[CustomEditor(NReactionDock)]
class NReactionDockEditor (Editor):
	def OnInspectorGUI():
		targetType as System.Type = target.GetType()
		targetFields as (FieldInfo) = targetType.GetFields(BindingFlags.Public | BindingFlags.Instance)
		
		for field as FieldInfo in targetFields:
			EditorGUILayout.BeginHorizontal()
			EditorGUILayout.PrefixLabel(field.Name)
			field.SetValue(target, editorGUILayoutForValue(field.GetValue(target)))
			EditorGUILayout.EndHorizontal()
	
	
	private def editorGUILayoutForValue(fieldValue as object) as object:
 		# built-ins
		
		if fieldValue isa System.Int32:
			return EditorGUILayout.IntField(fieldValue)
		
		if fieldValue isa System.Single:
			 return EditorGUILayout.FloatField(fieldValue)
		
		if fieldValue isa System.Array:
			fieldElementType as Type = fieldValue.GetType().GetElementType()
			castedFieldValue = fieldValue as (object)
			resultFieldValue as List = List()
			
			for fieldSubI in range(0, castedFieldValue.Length):
				EditorGUILayout.BeginHorizontal()
				EditorGUILayout.PrefixLabel(fieldSubI.ToString())
				resultFieldValue.Add(
					editorGUILayoutForValue( castedFieldValue[fieldSubI] )
				)
				EditorGUILayout.EndHorizontal()
			
			return array(fieldElementType, resultFieldValue)
		
		
		# Custom
		
		#if fieldValue isa Percentage:
		#	 return Percentage( EditorGUILayout.Slider(fieldValue.level, 0, 100) )
		
		
		return EditorGUILayout.TextField(fieldValue)
