/// Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
/// @author	Slippy Douglas
/// @purpose	Provides …


using System;
using System.Collections.Generic;
using System.Linq; // Concat()
//using System.Reflection;
using UnityEditor;
using UnityEngine;


static class NEventEditorGUILayout
{
	static public Type DerivedTypeField(Type selectedType, Type baseType)
	{
		return DerivedTypeFieldWithNone(selectedType, baseType, "None");
	}
	
	static public Type DerivedTypeField(Type selectedType, Type baseType, string noneEntry)
	{
		if (!String.IsNullOrEmpty(noneEntry))
			return DerivedTypeFieldWithNone(selectedType, baseType, noneEntry);
		else
			return DerivedTypeFieldWithoutNone(selectedType, baseType);
	}
	
	
	static private Type DerivedTypeFieldWithNone(Type selectedType, Type baseType, string noneEntry)
	{
		Type[] derivedTypes = FindDerivedTypes(baseType);
		
		int selectedTypeIndex = Array.FindIndex(
			derivedTypes,
			(Type t) => (t == selectedType)
		);
		int newTypeIndex = EditorGUILayout.Popup(
			selectedTypeIndex + 1,
			new string[]{ noneEntry }.Concat(FindDerivedTypeNames(baseType)).ToArray()
		) - 1;
		
		if (newTypeIndex < 0)
			return null;
		else
			return derivedTypes[newTypeIndex];
	}
	
	
	static private Type DerivedTypeFieldWithoutNone(Type selectedType, Type baseType)
	{
		Type[] derivedTypes = FindDerivedTypes(baseType);
		
		int selectedTypeIndex = Array.FindIndex(
			derivedTypes,
			(Type t) => (t == selectedType)
		);
		int newTypeIndex = EditorGUILayout.Popup(
			selectedTypeIndex,
			FindDerivedTypeNames(baseType)
		);
		
		return derivedTypes[newTypeIndex];
	}
	
	
	static private string[] FindDerivedTypeNames(Type baseType)
	{
		List<string> typeNames = new List<string>();
		foreach (Type type in FindDerivedTypes(baseType))
			typeNames.Add(type.Name);
		return typeNames.ToArray();
	}
	
	
	static private Type[] FindDerivedTypes(Type baseType)
	{
		return baseType.Module.FindTypes(DerivedTypeFilter, baseType);
	}
	
	static private bool DerivedTypeFilter(Type m, object filterCriteria)
	{
		return m.IsSubclassOf(filterCriteria as Type);
	}
	
	
	
	static public NEventAction EventActionField(NEventAction action)
	{
		EditorGUILayout.BeginVertical();
		
		
		Type actionEventType = null;
		if (action != null) {
			if (action.eventType == null)
				throw new ArgumentNullException("action.eventType");
			
			actionEventType = action.eventType.type;
		}
		
		Type resultEventType = DerivedTypeField(actionEventType, typeof(NEventBase));
		
		if (resultEventType == null) {
			action = null;
		} else {
			if (resultEventType != actionEventType) {
				if (action == null)
					action = new NEventAction(resultEventType);
				else
					action.eventType.type = resultEventType;
			}
			
			action.scope = (NEventAction.Scope)EditorGUILayout.EnumPopup(action.scope);
			
			if (action.scope == NEventAction.Scope.Specific)
				action.scopeSpecificGO = (GameObject)EditorGUILayout.ObjectField(action.scopeSpecificGO, typeof(GameObject));
			else if (action.scope == NEventAction.Scope.Named)
				action.scopeName = EditorGUILayout.TextField(action.scopeName);
			else if (action.scope == NEventAction.Scope.Tagged)
				action.scopeTag = EditorGUILayout.TextField(action.scopeTag);
		}
		
		
		EditorGUILayout.EndVertical();
		
		return action;
	}
	
	
	
	static public SerializableType SerializableTypeField(SerializableType field)
	{
		field.type = DerivedTypeField(field.type, typeof(object));
		return field;
	}
	
	static public SerializableDerivedType SerializableDerivedTypeField(SerializableDerivedType field)
	{
		if (field.baseType.type == null)
			throw new ArgumentNullException("field.baseType.type");
		
		field.type = DerivedTypeField(field.type, field.baseType.type);
		return field;
	}
	
	
	//static ICallable CallableField(ICallable field)
	//{
	//	Type resultType = DerivedTypeField(field.GetType(), typeof(MulticastDelegate)) // C#'s delegate operator / Boo's callable operator
	//	return field;
	//}
	
	
	
	static public NAbilityDock NAbilityField(NAbilityBase field)
	{
		NAbilityDock dock = null;
		if (field != null)
			dock = field.gameObject.GetComponent<NAbilityDock>();
		
		return (NAbilityDock)EditorGUILayout.ObjectField(dock, typeof(NAbilityDock));
		//return EditorGUILayout.ObjectField(fieldValue, fieldType);
	}
	
	static public NReactionDock NReactionField(NReactionBase field)
	{
		NReactionDock dock = null;
		if (field != null)
			dock = field.gameObject.GetComponent<NReactionDock>();
		
		return (NReactionDock)EditorGUILayout.ObjectField(dock, typeof(NReactionDock));
		//return EditorGUILayout.ObjectField(fieldValue, fieldType);
	}
	
	
	
	static public object AutoField(object fieldValue) {
		if (fieldValue == null)
			return AutoField(fieldValue, null);
		else
			return AutoField(fieldValue, fieldValue.GetType());
	}
	static public object AutoField(object fieldValue, Type fieldType)
	{
		// built-in value types
		
		if (fieldType == typeof(int))
			return EditorGUILayout.IntField((int)fieldValue);
		
		if (fieldType == typeof(float) || fieldType == typeof(double))
			return EditorGUILayout.FloatField((float)fieldValue);
		
		if (fieldType == typeof(string))
			return EditorGUILayout.TextField((string)fieldValue ?? "");
		
		if (fieldType == typeof(Vector2))
			return EditorGUILayout.Vector2Field("", (Vector2)fieldValue);
		
		if (fieldType == typeof(Vector3))
			return EditorGUILayout.Vector3Field("", (Vector3)fieldValue);
		
		if (fieldType == typeof(Vector4))
			return EditorGUILayout.Vector4Field("", (Vector4)fieldValue);
		
		if (fieldType == typeof(Rect))
			return EditorGUILayout.RectField((Rect)fieldValue);
		
		if (fieldType == typeof(Color))
			return EditorGUILayout.ColorField((Color)fieldValue);
		
		if (fieldType.IsSubclassOf(typeof(Enum)))
			return EditorGUILayout.EnumPopup((Enum)fieldValue);
		
		//if (fieldType.IsSubclassOf(typeof(MulticastDelegate))) // C#'s delegate operator / Boo's callable operator
		//	return CallableField(fieldValue)
		
		
		// custom types
		
		if (fieldType == typeof(SerializableType))
			return SerializableTypeField((SerializableType)fieldValue);
		
		if (fieldType == typeof(SerializableDerivedType))
			return SerializableDerivedTypeField((SerializableDerivedType)fieldValue);
		
		if (fieldType == typeof(NEventAction))
			return EventActionField((NEventAction)fieldValue);
		
		if (fieldType.IsSubclassOf(typeof(NAbilityBase)))
			return NAbilityField((NAbilityBase)fieldValue);
		
		if (fieldType.IsSubclassOf(typeof(NReactionBase)))
			return NReactionField((NReactionBase)fieldValue);
		
		
		// Unity types
		
		if (fieldType == typeof(GameObject))
			return EditorGUILayout.ObjectField((GameObject)fieldValue, typeof(GameObject));
		
		if (fieldType == typeof(UnityEngine.Object))
			return EditorGUILayout.ObjectField((UnityEngine.Object)fieldValue, fieldValue.GetType());
		
		
		// read-only field
		
		string fieldValueString = "Null ("+fieldType+")";
		if (fieldValue != null)
			fieldValueString = fieldValue.ToString();
		GUILayout.Label(fieldValueString);
		return fieldValueString;
	}
}
