using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using XLua;

[LuaCallCSharp]
public class LuaBindMouseBehaviour : LuaBindMonoBehaviourGenericsBase<LuaBindMouseBehaviour>
{
	private Action<LuaTable> luaOnMouseEnter;
	private Action<LuaTable> luaOnMouseOver;
	private Action<LuaTable> luaOnMouseDown;
	private Action<LuaTable> luaOnMouseDrag;
	private Action<LuaTable> luaOnMouseUp;
	private Action<LuaTable> luaOnMouseExit;
	private Action<LuaTable> luaOnMouseUpAsButton;

	public void Start()
	{
		mLuaTable.Get("onMouseEnter", out luaOnMouseEnter);
		mLuaTable.Get("onMouseOver", out luaOnMouseOver);
		mLuaTable.Get("onMouseDown", out luaOnMouseDown);
		mLuaTable.Get("onMouseDrag", out luaOnMouseDrag);
		mLuaTable.Get("onMouseUp", out luaOnMouseUp);
		mLuaTable.Get("onMouseExit", out luaOnMouseExit);
		mLuaTable.Get("onMouseUpAsButton", out luaOnMouseUpAsButton);
	}

	void OnMouseEnter()
	{
		if (luaOnMouseEnter != null) luaOnMouseEnter(mLuaTable);
	}
	void OnMouseOver()
	{
		if (luaOnMouseOver != null) luaOnMouseOver(mLuaTable);
	}
	void OnMouseDown()
	{
		if (luaOnMouseDown != null) luaOnMouseDown(mLuaTable);
	}
	void OnMouseDrag()
	{
		if (luaOnMouseDrag != null) luaOnMouseDrag(mLuaTable);
	}
	void OnMouseUp()
	{
		if (luaOnMouseUp != null) luaOnMouseUp(mLuaTable);
	}
	void OnMouseExit()
	{
		if (luaOnMouseExit != null) luaOnMouseExit(mLuaTable);
	}
	void OnMouseUpAsButton()
	{
		if (luaOnMouseUpAsButton != null) luaOnMouseUpAsButton(mLuaTable);
	}
}
