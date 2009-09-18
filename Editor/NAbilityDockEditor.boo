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
	
	static final kLabelStyle as GUIStyle
	
	static def constructor():
		kLabelStyle = GUIStyle(
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
			continue if listElement is null
			
			#EditorGUILayout.Separator()
			resultElement = LayOutElement(listElement)
			EditorGUILayout.Separator()
			if resultElement is not listElement:
				listHasBeenModified = true
				listElement = resultElement
		
		
		# clean up: destory objects that were marked to be removed
		if _elementsToRemove.Length != 0:
			for removeElement as NAbilityBase in _elementsToRemove:
				targetElementList.Remove(removeElement)
				ScriptableObject.DestroyImmediate(removeElement) # to prevent leaks
		
		
		if listHasBeenModified:
			if needsSort:
				targetElementList.Sort(TypeNameSortComparer())
			
			# send the array back
			target.abilities = array(NAbilityBase, targetElementList)
	
	
	private def LayOutElement(element as NAbilityBase) as NAbilityBase:
		EditorGUILayout.BeginHorizontal()
		
		EditorGUILayout.Foldout(true, ObjectNames.NicifyVariableName(element.abilityName))
		#GUILayout.Label()
		
		destroyPressed as bool = GUILayout.Button('Destory', GUILayout.Width(60))
		
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
			resultValue = NEditorGUILayout.AutoField(origValue)
			#if resultValue.GetType() == origValue.GetType():
			try:
				field.SetValue(element, resultValue)
			except e as Exception:
				pass
			
			EditorGUILayout.EndHorizontal()
		
		# private fields get set back to 0 when the game starts (probably a Unity thing)
		#privElementFields as (FieldInfo) = element.GetType().GetFields(kPrivFieldBindingFlags)
		#for field as FieldInfo in privElementFields:
		#	if typeof(NReactionBase).GetField(field.Name, kPubAndPrivFieldBindingFlags):
		#		continue
		#	
		#	EditorGUILayout.BeginHorizontal()
		#	GUILayout.Label("(initial) ${ObjectNames.NicifyVariableName(field.Name)}", kLabelStyle)
		#	
		#	origValue = field.GetValue(element)
		#	resultValue = NEditorGUILayout.AutoField(origValue)
		#	#if resultValue.GetType() == field.GetType():
		#	try:
		#		field.SetValue(element, resultValue)
		#	except e as Exception:
		#		pass
		#	
		#	EditorGUILayout.EndHorizontal()
		
		# setting properties cause all kind of problems since the property can trigger other stuff to happen
		#elementProperties as (PropertyInfo) = element.GetType().GetProperties(kPropertyBindingFlags)
		#for property as PropertyInfo in elementProperties:
		#	if typeof(NAbilityBase).GetProperty(property.Name, kPropertyBindingFlags):
		#		continue
		#	
		#	EditorGUILayout.BeginHorizontal()
		#	EditorGUILayout.PrefixLabel(ObjectNames.NicifyVariableName(property.Name))
		#	
		#	origValue = property.GetValue(element, null)
		#	resultValue = NEditorGUILayout.AutoField(origValue)
		#	if resultValue.GetType() == origValue.GetType():
		#		property.SetValue(element, resultValue, null)
		#	
		#	EditorGUILayout.EndHorizontal()
		#	EditorGUILayout.Separator()
		
		return element
	
	
	private def LayOutCreateWidget(elementList as List) as bool:
		didCreate as bool
		
		EditorGUILayout.BeginHorizontal()
		GUILayout.Label('Create', GUILayout.Width(50))
		
		createType as Type = NEditorGUILayout.DerivedTypeField(null, typeof(NAbilityBase), '\t')
		
		if createType is not null:
			didCreate = true
			createdElement as NAbilityBase = ScriptableObject().CreateInstance(createType.ToString())
			elementList.Add(createdElement)
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
