## Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
## @author	Slippy Douglas
## @purpose	Provides …


import System


[Serializable]
class SerializableType:
	# hand-edit at your own risk!
	public typeName as string
	
	type as Type:
		get:
			return null if String.IsNullOrEmpty(typeName)
			type as Type = Type.GetType(typeName)
			return type
		set:
			if value is not null:
				typeName = value.FullName
			else:
				typeName = null
