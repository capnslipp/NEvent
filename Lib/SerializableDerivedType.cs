/// Copyright © 2009 Slippy Douglas and Nectar Games. All rights reserved.
/// @author	Slippy Douglas
/// @purpose	Provides …


using System;
using UnityEngine;


[Serializable]
public class SerializableDerivedType
{
	// do not edit!
	[HideInInspector]
	public SerializableType baseType = new SerializableType();
	
	
	// hand-edit at your own risk!
	public string typeName;
	
	public Type type {
		get {
			if (String.IsNullOrEmpty(typeName))
				return null;
			
			Type type = Type.GetType(typeName);
			if (!type.IsSubclassOf(baseType.type))
				throw new ArgumentException(type.FullName+" must be derived from "+baseType.type.FullName, "type");
			
			return type;
		}
		set {
			if (value != null) {
				if (!value.IsSubclassOf(baseType.type))
					throw new ArgumentException(value.FullName+" must be derived from "+baseType.type.FullName);
				
				typeName = value.FullName;
			}
			else {
				typeName = null;
			}
		}
	}
	
	
	public SerializableDerivedType(Type theBaseType)
	{
		baseType.type = theBaseType;
	}
}
