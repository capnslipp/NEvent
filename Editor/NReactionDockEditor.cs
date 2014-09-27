/// Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
/// @author	Slippy Douglas
/// @purpose	Provides …


using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEditor;
using UnityEngine;


[CustomEditor(typeof(NReactionDock))]
class NReactionDockEditor : Editor
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
	
	
	protected List<NReactionBase> _elementsToRemove = new List<NReactionBase>();
	
	
	public override void OnInspectorGUI()
	{
		NReactionDock target = (NReactionDock)this.target;
		
		List<NReactionBase> targetElementList = new List<NReactionBase>(target.reactions);
		bool listHasBeenModified = false;
		bool needsSort = false;
		
		
		// create field
		if (LayOutCreateWidget(targetElementList)) {
			needsSort = true;
			listHasBeenModified = true;
		}
		
		
		// element fields
		for (int listElementI = targetElementList.Count - 1; listElementI >= 0; --listElementI) {
			NReactionBase listElement = targetElementList[listElementI];
			
			NReactionBase resultElement = LayOutElement(listElement);
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
			foreach (NReactionBase removeElement in _elementsToRemove) {
				targetElementList.Remove(removeElement);
				ScriptableObject.DestroyImmediate(removeElement); // to prevent leaks
			}
			
			_elementsToRemove.Clear();
		}
		
		
		if (listHasBeenModified) {
			if (needsSort)
				targetElementList.Sort(new TypeNameSortComparer());
			
			// send the array back
			target.reactions.Clear();
			target.reactions.AddRange(targetElementList);
		}
	}
	
	
	private NReactionBase LayOutElement(NReactionBase element)
	{
		EditorGUILayout.BeginHorizontal();
		
		string niceName = ObjectNames.NicifyVariableName(element.reactionName+" (on) "+element.eventName);
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
	
	
	private NReactionBase LayOutElementFields(NReactionBase element)
	{
		object origValue;
		object resultValue;
		
		FieldInfo[] pubElementFields = element.GetType().GetFields(kPubFieldBindingFlags);
		foreach (FieldInfo field in pubElementFields) {
			if (typeof(NReactionBase).GetField(field.Name, kPubFieldBindingFlags) != null)
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
	
	
	private bool LayOutCreateWidget(List<NReactionBase> elementList)
	{
		bool didCreate;
		
		EditorGUILayout.BeginHorizontal();
		GUILayout.Label("Create", GUILayout.Width(50));
		
		Type createType = NEventEditorGUILayout.DerivedTypeField(null, typeof(NReactionBase), "\t");
		
		if (createType != null) {
			NReactionBase createdElement = ScriptableObject.CreateInstance(createType.ToString()) as NReactionBase;
			elementList.Add(createdElement);
			didCreate = true;
		}
		else {
			didCreate = false;
		}
		
		EditorGUILayout.EndHorizontal();
		
		return didCreate;
	}
	
	
	class TypeNameSortComparer : Comparer<NReactionBase>
	{
		public override int Compare(NReactionBase early, NReactionBase late)
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
