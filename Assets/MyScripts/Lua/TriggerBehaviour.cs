using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using XLua;

namespace GameLua 
{
	[LuaCallCSharp]
	public class TriggerBehaviour : LuaBindMonoBehaviourGenericsBase<TriggerBehaviour>
	{
		private Action<LuaTable, Collider> luaOnTriggerEnter;
		private Action<LuaTable, Collider> luaOnTriggerStay;
		private Action<LuaTable, Collider> luaOnTriggerExit;

		public void Start()
		{
			mLuaTable.Get("onTriggerEnter", out luaOnTriggerEnter);
			mLuaTable.Get("onTriggerStay", out luaOnTriggerStay);
			mLuaTable.Get("onTriggerExit", out luaOnTriggerExit);
		}

		void OnTriggerEnter(Collider collider)
		{
			if (luaOnTriggerEnter != null) luaOnTriggerEnter(mLuaTable, collider);
		}

		void OnTriggerStay(Collider collider)
		{
			if (luaOnTriggerStay != null) luaOnTriggerStay(mLuaTable, collider);
		}

		void OnTriggerExit(Collider collider)
		{
			if (luaOnTriggerExit != null) luaOnTriggerExit(mLuaTable, collider);
		}
	}
}