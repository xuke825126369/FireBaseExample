using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using XLua;

[LuaCallCSharp]
public class LuaBindApplicationBehaviour : LuaBindMonoBehaviourGenericsBase<LuaBindApplicationBehaviour>
{
	private Action<LuaTable, bool> luaOnApplicationFocus;
	private Action<LuaTable, bool> luaOnApplicationPause;

	public void Start()
	{
		mLuaTable.Get("OnApplicationFocus", out luaOnApplicationFocus);
		mLuaTable.Get("OnApplicationPause", out luaOnApplicationPause);
	}
		
	void OnApplicationFocus(bool focusStatus)
	{
		if (luaOnApplicationFocus != null) luaOnApplicationFocus(mLuaTable, focusStatus);
	}

	void OnApplicationPause(bool pauseStatus)
	{
		if (luaOnApplicationPause != null) luaOnApplicationPause(mLuaTable, pauseStatus);
	}
}
