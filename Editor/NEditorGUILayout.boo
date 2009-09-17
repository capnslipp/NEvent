## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
#import System.Reflection
import UnityEditor
#import UnityEngine


class NEditorGUILayout:
	static def DerivedTypeField(selectedType as Type, baseType as Type) as Type:
		derivedTypes as (Type) = FindDerivedTypes(baseType)
		
		selectedTypeIndex as int = Array.FindIndex(
			derivedTypes,
			{ t as Type | t == selectedType }
		)
		newTypeIndex as int = EditorGUILayout.Popup(
			selectedTypeIndex + 1,
			('None',) + FindDerivedTypeNames(typeof(NReactionBase))
		) - 1
		
		if newTypeIndex < 0:
			return null
		else:
			return derivedTypes[newTypeIndex]
	
	
	static private def FindDerivedTypeNames(baseType as Type) as (string):
		typeNames as (string) = array(string, 0)
		for type as Type in FindDerivedTypes(NReactionBase):
			typeNames += (type.Name,)
		return typeNames
	
	
	static private def FindDerivedTypes(baseType as Type) as (Type):
		return baseType.Module.FindTypes(DerivedTypeFilter, baseType)
	
	static private def DerivedTypeFilter(m as Type, filterCriteria as object) as bool:
		return m.IsSubclassOf(filterCriteria as Type)