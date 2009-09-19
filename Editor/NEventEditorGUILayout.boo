## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
#import System.Reflection
import UnityEditor
import UnityEngine


class NEventEditorGUILayout:
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
		EditorGUILayout.BeginVertical()
		
		
		actionEventType as Type = null
		if action is not null:
			assert action.eventType is not null
			actionEventType = action.eventType.type
		
		resultEventType as Type = DerivedTypeField(actionEventType, NEventBase)
		
		if resultEventType is null:
			action = null
		else:
			if resultEventType != actionEventType:
				if action is null:
					action = NEventAction(resultEventType)
				else:
					action.eventType.type = resultEventType
			
			action.scope = EditorGUILayout.EnumPopup(action.scope)
			
			if action.scope == NEventAction.Scope.Specific:
				action.scopeSpecificGO = EditorGUILayout.ObjectField(action.scopeSpecificGO, GameObject)
			elif action.scope == NEventAction.Scope.Named:
				action.scopeName = EditorGUILayout.TextField(action.scopeName)
			elif action.scope == NEventAction.Scope.Tagged:
				action.scopeTag = EditorGUILayout.TextField(action.scopeTag)
		
		
		EditorGUILayout.EndVertical()
		
		return action
	
	
	
	static def SerializableTypeField(field as SerializableType) as SerializableType:
		field.type = DerivedTypeField(field.type, object)
		return field
	
	static def SerializableDerivedTypeField(field as SerializableDerivedType) as SerializableDerivedType:
		assert field.baseType.type is not null
		field.type = DerivedTypeField(field.type, field.baseType.type)
		return field
	
	
	
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
		
		if fieldType == SerializableType:
			return SerializableTypeField(fieldValue)
		
		if fieldType == SerializableDerivedType:
			return SerializableDerivedTypeField(fieldValue)
		
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
