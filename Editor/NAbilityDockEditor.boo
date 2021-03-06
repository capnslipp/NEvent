## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
import System.Collections
import System.Reflection
import UnityEditor
import UnityEngine


[CustomEditor(NAbilityDock)]
class NAbilityDockEditor (Editor):
	static final kPubFieldBindingFlags as BindingFlags = BindingFlags.Public | BindingFlags.Instance
	#static final kPrivFieldBindingFlags as BindingFlags = BindingFlags.NonPublic | BindingFlags.Instance
	#static final kPubAndPrivFieldBindingFlags as BindingFlags = BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance
	#static final kPropertyBindingFlags as BindingFlags = BindingFlags.Public | BindingFlags.Instance
	
	static final kLabelStyle as GUIStyle = GUIStyle(
		margin: RectOffset(left: 20),
		padding: RectOffset(),
		alignment: TextAnchor.MiddleLeft,
		fixedWidth: 150,
		stretchWidth: false
	)
	
	
	_elementsToRemove as (NAbilityBase) = array(NAbilityBase, 0)
	
	
	def OnInspectorGUI():
		targetElementList as List = List(target.abilities as (NAbilityBase))
		listHasBeenModified as bool = false
		needsSort as bool = false
		
		
		# create field
		if LayOutCreateWidget(targetElementList):
			needsSort = true
			listHasBeenModified = true
		
		
		# element fields
		for listElement as NAbilityBase in targetElementList:
			resultElement as NAbilityBase = LayOutElement(listElement)
			EditorGUILayout.Separator()
			
			if resultElement is not listElement:
				listHasBeenModified = true
				listElement = resultElement # this actually won't do anything if the resultElement is a different type (i.e null)
		
		
		# clean up: destory objects that were marked to be removed
		if _elementsToRemove.Length > 0:
			for removeElement as NAbilityBase in _elementsToRemove:
				targetElementList.Remove(removeElement)
				ScriptableObject.DestroyImmediate(removeElement) # to prevent leaks
			
			_elementsToRemove = array(NAbilityBase, 0)
		
		
		if listHasBeenModified:
			if needsSort:
				targetElementList.Sort(TypeNameSortComparer())
			
			# send the array back
			target.abilities = array(NAbilityBase, targetElementList)
	
	
	private def LayOutElement(element as NAbilityBase) as NAbilityBase:
		EditorGUILayout.BeginHorizontal()
		
		niceName as string = ObjectNames.NicifyVariableName(element.abilityName)
		EditorGUILayout.Foldout(true, niceName)
		#GUILayout.Label(niceName)
		
		destroyPressed as bool = GUILayout.Button('Destroy', GUILayout.Width(60))
		
		EditorGUILayout.EndHorizontal()
		
		if destroyPressed:
			_elementsToRemove += (element,)
			return null
		else:
			element = LayOutElementFields(element)
			return element
	
	
	private def LayOutElementFields(element as NAbilityBase) as NAbilityBase:
		origValue as object
		resultValue as object
		
		pubElementFields as (FieldInfo) = element.GetType().GetFields(kPubFieldBindingFlags)
		for field as FieldInfo in pubElementFields:
			if typeof(NAbilityBase).GetField(field.Name, kPubFieldBindingFlags):
				continue
			
			EditorGUILayout.BeginHorizontal()
			GUILayout.Label(ObjectNames.NicifyVariableName(field.Name), kLabelStyle)
			
			origValue = field.GetValue(element)
			resultValue = NEventEditorGUILayout.AutoField(origValue, field.FieldType)
			
			try:
				field.SetValue(element, resultValue)
			except e as Exception:
				pass
			
			EditorGUILayout.EndHorizontal()
		
		# cannot use private fields or properties because:
		# 	private fields get set back to 0 when the game starts (probably a Unity thing)
		# 	setting properties cause all kind of problems since the property can trigger other stuff to happen
		
		return element
	
	
	private def LayOutCreateWidget(elementList as List) as bool:
		didCreate as bool
		
		EditorGUILayout.BeginHorizontal()
		GUILayout.Label('Create', GUILayout.Width(50))
		
		createType as Type = NEventEditorGUILayout.DerivedTypeField(null, typeof(NAbilityBase), '\t')
		
		if createType is not null:
			createdElement as NAbilityBase = ScriptableObject().CreateInstance(createType.ToString())
			elementList.Add(createdElement)
			didCreate = true
		else:
			didCreate = false
		
		EditorGUILayout.EndHorizontal()
		
		return didCreate
	
	
	class TypeNameSortComparer (IComparer):
		def IComparer.Compare(early as object, late as object) as int:
			if early.GetType() == late.GetType():
				return (early as UnityEngine.Object).GetInstanceID().CompareTo(
					(late as UnityEngine.Object).GetInstanceID()
				)
			else:
				return early.GetType().Name.CompareTo(
					late.GetType().Name
				)
