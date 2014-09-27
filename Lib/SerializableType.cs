/// Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
/// @author	Slippy Douglas
/// @purpose	Provides …


using System;


[Serializable]
public class SerializableType
{
	// hand-edit at your own risk!
	public string typeName;
	
	public Type type {
		get {
			if (String.IsNullOrEmpty(typeName))
				return null;
			
			Type type = Type.GetType(typeName);
			return type;
		}
		set {
			if (value != null)
				typeName = value.FullName;
			else
				typeName = null;
		}
	}
}
