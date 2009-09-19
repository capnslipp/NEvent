## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System
import UnityEngine


[Serializable]
class SerializableDerivedType:
	# do not edit!
	[HideInInspector]
	public baseType as SerializableType = SerializableType()
	
	
	# hand-edit at your own risk!
	public typeName as string
	
	type as Type:
		get:
			return null if String.IsNullOrEmpty(typeName)
			type as Type = Type.GetType(typeName)
			assert type.IsSubclassOf(baseType.type), "${type.FullName} must be derived from ${baseType.type.FullName}"
			return type
		set:
			if value is not null:
				assert value.IsSubclassOf(baseType.type), "${value.FullName} must be derived from ${baseType.type.FullName}"
				typeName = value.FullName
			else:
				typeName = null
	
	
	def constructor(theBaseType as Type):
		baseType.type = theBaseType
