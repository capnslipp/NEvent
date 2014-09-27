/// Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
/// @author	Slippy Douglas
/// @purpose	Provides …


using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEditor;
using UnityEngine;


[CustomEditor(typeof(NAbilityDock))]
class NAbilityDockEditor : Editor
{
	static readonly BindingFlags kPubFieldBindingFlags = BindingFlags.Public | BindingFlags.Instance;
	//static readonly BindingFlags kPrivFieldBindingFlags = BindingFlags.NonPublic | BindingFlags.Instance;
	//static readonly BindingFlags kPubAndPrivFieldBindingFlags = BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance;
	//static readonly BindingFlags kPropertyBindingFlags = BindingFlags.Public | BindingFlags.Instance;
	
	static readonly GUIStyle kLabelStyle = new GUIStyle {
		margin = new RectOffset { left = 20 },
		padding = new RectOffset(),
		alignment = TextAnchor.MiddleLeft,
		fixedWidth = 150,
		stretchWidth = false
	};
	
	
	protected List<NAbilityBase> _elementsToRemove = new List<NAbilityBase>();
	
	
	public override void OnInspectorGUI()
	{
		NAbilityDock target = (NAbilityDock)this.target;
		
		List<NAbilityBase> targetElementList = new List<NAbilityBase>(target.abilities);
		bool listHasBeenModified = false;
		bool needsSort = false;
		
		
		// create field
		if (LayOutCreateWidget(targetElementList)) {
			needsSort = true;
			listHasBeenModified = true;
		}
		
		
		// element fields
		for (int listElementI = targetElementList.Count - 1; listElementI >= 0; --listElementI) {
			NAbilityBase listElement = targetElementList[listElementI];
			
			NAbilityBase resultElement = LayOutElement(listElement);
			EditorGUILayout.Separator();
			
			if (resultElement != listElement) {
				listHasBeenModified = true;
				if (resultElement == null)
					targetElementList.RemoveAt(listElementI);
				else
					targetElementList[listElementI] = resultElement;
			}
		}
		
		
		// clean up: destory objects that were marked to be removed
		if (_elementsToRemove.Count > 0) {
			foreach (NAbilityBase removeElement in _elementsToRemove) {
				targetElementList.Remove(removeElement);
				ScriptableObject.DestroyImmediate(removeElement); // to prevent leaks
			}
			
			_elementsToRemove.Clear();
		}
		
		
		if (listHasBeenModified) {
			if (needsSort)
				targetElementList.Sort(new TypeNameSortComparer());
			
			// send the array back
			target.abilities.Clear();
			target.abilities.AddRange(targetElementList);
		}
	}
	
	
	private NAbilityBase LayOutElement(NAbilityBase element)
	{
		EditorGUILayout.BeginHorizontal();
		
		string niceName = ObjectNames.NicifyVariableName(element.abilityName);
		EditorGUILayout.Foldout(true, niceName);
		//GUILayout.Label(niceName);
		
		bool destroyPressed = GUILayout.Button("Destroy", GUILayout.Width(60));
		
		EditorGUILayout.EndHorizontal();
		
		if (destroyPressed) {
			_elementsToRemove.Add(element);
			return null;
		}
		else {
			element = LayOutElementFields(element);
			return element;
		}
	}
	
	
	private NAbilityBase LayOutElementFields(NAbilityBase element)
	{
		object origValue;
		object resultValue;
		
		FieldInfo[] pubElementFields = element.GetType().GetFields(kPubFieldBindingFlags);
		foreach (FieldInfo field in pubElementFields) {
			if (typeof(NAbilityBase).GetField(field.Name, kPubFieldBindingFlags) != null)
				continue;
			
			EditorGUILayout.BeginHorizontal();
			GUILayout.Label(ObjectNames.NicifyVariableName(field.Name), kLabelStyle);
			
			origValue = field.GetValue(element);
			resultValue = NEventEditorGUILayout.AutoField(origValue, field.FieldType);
			
			try {
				field.SetValue(element, resultValue);
			}
			catch (Exception) {}
			
			EditorGUILayout.EndHorizontal();
		}
		
		// cannot use private fields or properties because:
		// 	private fields get set back to 0 when the game starts (probably a Unity thing)
		// 	setting properties cause all kind of problems since the property can trigger other stuff to happen
		
		return element;
	}
	
	
	private bool LayOutCreateWidget(List<NAbilityBase> elementList)
	{
		bool didCreate;
		
		EditorGUILayout.BeginHorizontal();
		GUILayout.Label("Create", GUILayout.Width(50));
		
		Type createType = NEventEditorGUILayout.DerivedTypeField(null, typeof(NAbilityBase), "\t");
		
		if (createType != null) {
			NAbilityBase createdElement = ScriptableObject.CreateInstance(createType.ToString()) as NAbilityBase;
			elementList.Add(createdElement);
			didCreate = true;
		}
		else {
			didCreate = false;
		}
		
		EditorGUILayout.EndHorizontal();
		
		return didCreate;
	}
	
	
	class TypeNameSortComparer : Comparer<NAbilityBase>
	{
		public override int Compare(NAbilityBase early, NAbilityBase late)
		{
			if (early.GetType() == late.GetType()) {
				return early.GetInstanceID().CompareTo(
					late.GetInstanceID()
				);
			}
			else {
				return early.GetType().Name.CompareTo(
					late.GetType().Name
				);
			}
		}
	}
}
