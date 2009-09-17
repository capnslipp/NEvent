## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
import System.Collections
import UnityEditor
import UnityEngine


[CustomEditor(NAbilityDock)]
class NAbilityDockEditor (Editor):
	_elementsToRemove as (NAbilityBase) = array(NAbilityBase, 0)
	
	
	def OnInspectorGUI():
		targetElementList as List = List(target.abilities as (NAbilityBase))
		listHasBeenModified as bool = false
		
		
		# element fields
		for listElement as NAbilityBase in targetElementList:
			resultElement = LayOutElement(listElement)
			if resultElement is not listElement:
				listHasBeenModified = true
				listElement = resultElement
		
		
		# create field
		if LayOutCreate(targetElementList):
			listHasBeenModified = true
		
		
		# clean up: destory objects that were marked to be removed
		if _elementsToRemove.Length != 0:
			for removeElement as NAbilityBase in _elementsToRemove:
				targetElementList.Remove(removeElement)
				ScriptableObject.DestroyImmediate(removeElement) # to prevent leaks
		
		
		if listHasBeenModified:
			# sort
			targetElementList.Sort(TypeNameSortComparer())
			
			# send the array back
			target.abilities = array(NAbilityBase, targetElementList)
	
	
	private def LayOutElement(element as NAbilityBase) as NAbilityBase:
		EditorGUILayout.BeginHorizontal()
		
		elementType as Type = element.GetType()
		GUILayout.Label(elementType.Name)
		
		destroyPressed as bool = GUILayout.Button('Destory', GUILayout.Width(60))
		if destroyPressed:
			_elementsToRemove += (element,)
		
		EditorGUILayout.EndHorizontal()
		
		if destroyPressed:
			return null
	
	
	private def LayOutCreate(elementList as List) as bool:
		didCreate as bool
		
		EditorGUILayout.BeginHorizontal()
		EditorGUILayout.PrefixLabel('Create')
		
		createType as Type = NEditorGUILayout.DerivedTypeField(null, typeof(NAbilityBase), '\t')
		#createPressed as bool = GUILayout.Button('Create')
		
		if createType is not null:
			didCreate = true
			elementList.Add( ScriptableObject().CreateInstance(createType.ToString()) )
		else:
			didCreate = false
		
		EditorGUILayout.EndHorizontal()
		
		return didCreate
	
	
	class TypeNameSortComparer (IComparer):
		def IComparer.Compare(early as object, late as object) as int:
			if early is null and late is null:
				return 0
			elif early is null:
				return 1
			elif late is null:
				return -1
			else:
				return early.GetType().Name.CompareTo( late.GetType().Name )
