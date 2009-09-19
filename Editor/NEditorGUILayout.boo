## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
#import System.Reflection
import UnityEditor
import UnityEngine


class NEditorGUILayout:
	static def DerivedTypeField(selectedType as Type, baseType as Type) as Type:
		return DerivedTypeFieldWithNone(selectedType, baseType, 'None')
	
	static def DerivedTypeField(selectedType as Type, baseType as Type, noneEntry as string) as Type:
		if not String.IsNullOrEmpty(noneEntry):
			return DerivedTypeFieldWithNone(selectedType, baseType, noneEntry)
		else:
			return DerivedTypeFieldWithoutNone(selectedType, baseType)
	
	
	static private def DerivedTypeFieldWithNone(selectedType as Type, baseType as Type, noneEntry as string) as Type:
		derivedTypes as (Type) = FindDerivedTypes(baseType)
		
		selectedTypeIndex as int = Array.FindIndex(
			derivedTypes,
			{ t as Type | t == selectedType }
		)
		newTypeIndex as int = EditorGUILayout.Popup(
			selectedTypeIndex + 1,
			(noneEntry,) + FindDerivedTypeNames(baseType)
		) - 1
		
		if newTypeIndex < 0:
			return null
		else:
			return derivedTypes[newTypeIndex]
	
	
	static private def DerivedTypeFieldWithoutNone(selectedType as Type, baseType as Type) as Type:
		derivedTypes as (Type) = FindDerivedTypes(baseType)
		
		selectedTypeIndex as int = Array.FindIndex(
			derivedTypes,
			{ t as Type | t == selectedType }
		)
		newTypeIndex as int = EditorGUILayout.Popup(
			selectedTypeIndex,
			FindDerivedTypeNames(baseType)
		)
		
		return derivedTypes[newTypeIndex]
	
	
	static private def FindDerivedTypeNames(baseType as Type) as (string):
		typeNames as (string) = array(string, 0)
		for type as Type in FindDerivedTypes(baseType):
			typeNames += (type.Name,)
		return typeNames
	
	
	static private def FindDerivedTypes(baseType as Type) as (Type):
		return baseType.Module.FindTypes(DerivedTypeFilter, baseType)
	
	static private def DerivedTypeFilter(m as Type, filterCriteria as object) as bool:
		return m.IsSubclassOf(filterCriteria as Type)
	
	
	
	static def EventActionField(action as NEventAction) as NEventAction:
		actionType as Type = null
		actionType = action.noteType if action is not null
		
		resultType as Type = DerivedTypeField(actionType, NEventBase)
		
		if resultType is null:
			return null
		elif resultType != actionType:
			return NEventAction(resultType)
		else:
			return action
	
	
	
	static def AutoField(fieldValue as object) as object:
		if fieldValue is null:
			return AutoField(fieldValue, null)
		else:
			return AutoField(fieldValue, fieldValue.GetType())
	
	static def AutoField(fieldValue as object, fieldType as Type) as object:
		# built-in value types
		
		if fieldType == int:
			return EditorGUILayout.IntField(fieldValue)
		
		if fieldType == single or fieldType == double:
			return EditorGUILayout.FloatField(fieldValue)
		
		if fieldType == string:
			return EditorGUILayout.TextField(fieldValue)
		
		if fieldType == Vector2:
			return EditorGUILayout.Vector2Field('', cast(Vector2, fieldValue))
		
		if fieldType == Vector3:
			return EditorGUILayout.Vector3Field('', cast(Vector3, fieldValue))
		
		if fieldType == Vector4:
			return EditorGUILayout.Vector4Field('', cast(Vector4, fieldValue))
		
		if fieldType == Rect:
			return EditorGUILayout.RectField(cast(Rect, fieldValue))
		
		if fieldType == Color:
			return EditorGUILayout.ColorField(cast(Color, fieldValue))
		
		
		# custom types
		
		if fieldType == NEventAction:
			return EventActionField(fieldValue)
		
		
		# Unity types
		
		if fieldType == GameObject:
			return EditorGUILayout.ObjectField(cast(GameObject, fieldValue), GameObject)
		
		if fieldType == UnityEngine.Object:
			return EditorGUILayout.ObjectField(fieldValue, fieldValue.GetType())
		
		
		# read-only field
		
		fieldValueString as string = "Null (${fieldType})"
		fieldValueString = fieldValue.ToString() if fieldValue is not null
		GUILayout.Label(fieldValueString)
		return fieldValueString
