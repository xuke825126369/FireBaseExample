using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using XLua;

namespace GameLua 
{
	[LuaCallCSharp]
	public class CollisionBehaviour : LuaBindMonoBehaviourGenericsBase<CollisionBehaviour>
	{
		private Action<LuaTable, Collision> luaOnCollisionEnter;
		private Action<LuaTable, Collision> luaOnCollisionStay;
		private Action<LuaTable, Collision> luaOnCollisionExit;
		
		public void Start()
		{
			mLuaTable.Get("onCollisionEnter", out luaOnCollisionEnter);
			mLuaTable.Get("onCollisionStay", out luaOnCollisionStay);
			mLuaTable.Get("onCollisionExit", out luaOnCollisionExit);
		}

		void OnCollisionEnter(Collision collision)
		{
			if (luaOnCollisionEnter != null) luaOnCollisionEnter(mLuaTable, collision);
		}
		void OnCollisionStay(Collision collision)
		{
			if (luaOnCollisionStay != null) luaOnCollisionStay(mLuaTable, collision);
		}
		void OnCollisionExit(Collision collision)
		{
			if (luaOnCollisionExit != null) luaOnCollisionExit(mLuaTable, collision);
		}
	}
}
