using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using XLua;
using System;

[LuaCallCSharp]
public class LuaBindBasicMonoBehaviour : LuaBindMonoBehaviourGenericsBase<LuaBindBasicMonoBehaviour>
{
    private Action<LuaTable> luaOnEnable = null;
    private Action<LuaTable> luaStart = null;
	private Action<LuaTable> luaOnDisable = null;
	private Action<LuaTable> luaOnDestroy = null;

	private bool bInit = false;
    private void Init()
    {
		if (bInit) return;
        if (mLuaTable == null) return;
        mLuaTable.Get("luaOnEnable", out luaOnEnable);
        mLuaTable.Get("Start", out luaStart);
        mLuaTable.Get("OnDisable", out luaOnDisable);
        mLuaTable.Get("OnDestroy", out luaOnDestroy);
        bInit = true;
    }

    private void Awake()
    {
        Init();
    }

    void OnEnable()
    {
        Init();
        if (luaOnEnable != null) luaOnEnable(mLuaTable);
    }

    public void Start()
	{
        Init();
        if (luaStart != null) luaStart(mLuaTable);
	}

	void OnDisable()
	{
        Init();
        if (luaOnDisable != null) luaOnDisable(mLuaTable);
	}

	void OnDestroy()
	{
        if (luaOnDestroy != null) luaOnDestroy(mLuaTable);

		luaStart = null;
		luaOnDisable = null;
		luaOnDestroy = null;

	}
}
