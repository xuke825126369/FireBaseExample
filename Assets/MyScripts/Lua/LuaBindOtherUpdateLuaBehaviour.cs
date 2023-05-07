using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using XLua;

[LuaCallCSharp]
public class LuaBindOtherUpdateLuaBehaviour : LuaBindMonoBehaviourGenericsBase<LuaBindOtherUpdateLuaBehaviour>
{
	private Action<LuaTable> luaFixedUpdate;
	private Action<LuaTable> luaLateUpdate;
	
	public void Start()
	{
		mLuaTable.Get("FixedUpdate", out luaFixedUpdate);
		mLuaTable.Get("LateUpdate", out luaLateUpdate);
	}

	void FixedUpdate()
	{
		if (luaFixedUpdate != null) luaFixedUpdate(mLuaTable);
	}

	void LateUpdate()
	{
		if (luaLateUpdate != null) luaLateUpdate(mLuaTable);
	}

	private void OnDestroy()
	{
		luaFixedUpdate = null;
		luaLateUpdate = null;
	}
}