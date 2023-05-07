using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;
using System;

public abstract class LuaBindMonoBehaviourBase : MonoBehaviour
{
	protected LuaTable mLuaTable = null;

	public static void UnBind(GameObject obj, LuaTable mLuaTable)
	{
		if (obj == null) return;
		foreach (var behaviour in obj.GetComponents<LuaBindMonoBehaviourBase>())
		{
			if (behaviour.mLuaTable == mLuaTable)
			{
				Destroy(behaviour);
			}
		}
	}

	public static void UnBindAll(GameObject obj)
	{
		if (obj == null) return;
		foreach (var behaviour in obj.GetComponents<LuaBindMonoBehaviourBase>())
		{
			Destroy(behaviour);
		}
	}
}

public abstract class LuaBindMonoBehaviourGenericsBase<T> : LuaBindMonoBehaviourBase where T : LuaBindMonoBehaviourGenericsBase<T>
{
	public static T Bind(GameObject obj, LuaTable mLuaTable)
	{
		T behaviour = obj.AddComponent<T>();
		behaviour.mLuaTable = mLuaTable;
		return behaviour;
	}
}

