using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[XLua.LuaCallCSharp]
public class TestUserHelper : Singleton<TestUserHelper>
{
	public string GetTestUserId()
	{
		if (!PlayerPrefs.HasKey("TestUserId") || string.IsNullOrWhiteSpace(PlayerPrefs.GetString("TestUserId")))
		{
			string uuId = SystemInfo.deviceUniqueIdentifier;
			PlayerPrefs.SetString("TestUserId", uuId);
			PlayerPrefs.Save();
		}
		return PlayerPrefs.GetString("TestUserId");
	}
}
