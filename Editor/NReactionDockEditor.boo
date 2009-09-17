## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
import System.Collections
import UnityEditor
import UnityEngine


[CustomEditor(NReactionDock)]
class NReactionDockEditor (Editor):
	def OnInspectorGUI():
		targetReactionsList as List = List(target.reactions as (NReactionBase))
		listHasBeenModified as bool = false
		
		
		# size field
		
		#EditorGUILayout.BeginHorizontal()
		#EditorGUILayout.PrefixLabel('Size')
		#
		#origLength as int = targetReactionsList.Count
		#newLength as int = EditorGUILayout.IntField(origLength)
		#
		## if the requested size is longer, add null elements to the end
		#if newLength > origLength:
		#	listHasBeenModified = true
		#	for newI as int in range(newLength - origLength):
		#		targetReactionsList.Add(null)
		## if the requested size is shorter, remove elements from the end
		#elif origLength > newLength:
		#	listHasBeenModified = true
		#	for oldI as int in range(origLength - newLength):
		#		targetReactionsList.Pop()
		#
		#EditorGUILayout.EndHorizontal()
		
		
		# element fields
		elementIndexesToRemove as (int) = array(int, 0)
		
		for listI as int in range(targetReactionsList.Count):
			EditorGUILayout.BeginHorizontal()
			#EditorGUILayout.PrefixLabel("Element ${listI}")
			
			origObject as NReactionBase = targetReactionsList[listI]
			resultObject as NReactionBase = EditableGUILayoutForValue(origObject)
			if origObject is not resultObject:
				listHasBeenModified = true
				targetReactionsList[listI] = resultObject
			
			destroyPressed as bool = GUILayout.Button('Destory')
			if destroyPressed:
				listHasBeenModified = true
				elementIndexesToRemove += (listI,)
			
			EditorGUILayout.EndHorizontal()
		
		if elementIndexesToRemove.Length != 0:
			for removeIndex as int in elementIndexesToRemove:
				targetReactionsList.RemoveAt(removeIndex)
		
		
		# create field
		
		EditorGUILayout.BeginHorizontal()
		EditorGUILayout.PrefixLabel('Create')
		
		createType as Type = NEditorGUILayout.DerivedTypeField(null, typeof(NReactionBase), '\t')
		#createPressed as bool = GUILayout.Button('Create')
		
		if createType is not null:
			listHasBeenModified = true
			targetReactionsList.Add( ScriptableObject().CreateInstance(createType.ToString()) )
		
		EditorGUILayout.EndHorizontal()	
		
		
		if listHasBeenModified:
			targetReactionsList.Sort(TypeNameSortComparer())
			target.reactions = array(NReactionBase, targetReactionsList)
	
	
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
	
	
	#private def viewableGUILayoutForValue(fieldValue as NReactionBase) as void:
	#	GUILayout.Label( fieldValue.GetType().ToString() )
	
	
	private def EditableGUILayoutForValue(fieldValue as NReactionBase) as NReactionBase:
		fieldValueType as Type
		fieldValueType = fieldValue.GetType() if fieldValue is not null
		
		resultType as Type = NEditorGUILayout.DerivedTypeField(fieldValueType, typeof(NReactionBase), null)
		
		if fieldValueType == resultType:
			return fieldValue
		else:
			if resultType is null:
				return null
			else:
				return ScriptableObject().CreateInstance(resultType.ToString())
