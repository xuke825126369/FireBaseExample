using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;
using System;

[LuaCallCSharp]
public class LuaBindUpdateMonoBehaviour : LuaBindMonoBehaviourGenericsBase<LuaBindUpdateMonoBehaviour>
{
	private Action<LuaTable> luaUpdate = null;

	public void Start()
	{
		mLuaTable.Get("Update", out luaUpdate);
	}

	void Update()
	{
		if (luaUpdate != null) luaUpdate(mLuaTable);
	}

	private void OnDestroy()
	{
		luaUpdate = null;
	}
}
