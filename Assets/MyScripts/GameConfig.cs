using SlotsMania;
using UnityEngine;
using XLua;

[XLua.LuaCallCSharp]
public class GameConfig : SingleTonMonoBehaviour<GameConfig>
{
	public int m_nThemeTestType = 0;
	public enumReturnRateTYPE m_enumReturnRateTYPE = enumReturnRateTYPE.enumReturnType_None;
	public bool orUseAssetBundle = false;
	public const string WebUrlRoot = "https://youxi.blob.core.windows.net/witchslots-android/";
	
#if UNITY_EDITOR
    public const bool PLATFORM_EDITOR = true;
#else
	public const bool PLATFORM_EDITOR = false;
#endif

#if UNITY_ANDROID
	public const bool PLATFORM_ANDROID = true;
#else
	public const bool PLATFORM_ANDROID = false;
#endif

#if UNITY_IOS
	public const bool PLATFORM_IOS = true;
#else
	public const bool PLATFORM_IOS = false;
#endif

	public void Init()
	{
#if UNITY_EDITOR

#else
		orUseAssetBundle = true;
		m_nThemeTestType = -1;
		m_enumReturnRateTYPE = enumReturnRateTYPE.enumReturnType_None;
#endif
		if (PLATFORM_EDITOR)
		{
			if (PLATFORM_ANDROID)
			{
				Debug.Log("当前平台: Editor Android");
			}
			else if (PLATFORM_IOS)
			{
				Debug.Log("当前平台: Editor IOS");
			}
			else
			{
				Debug.Log("当前平台: Editor");
			}
		}
		else if (PLATFORM_ANDROID)
		{
			Debug.Log("当前平台: Android");
		}
		else if (PLATFORM_IOS)
		{
			Debug.Log("当前平台: IOS");
		}
		else
		{
			Debug.Assert(false);
		}
	}

	public bool orTestUser()
	{
		if (PLATFORM_EDITOR)
		{
			return true;
		}

		if (GameBootConfig.readOnlyInstance == null)
        {
			return false;
        }

        string testUserId = TestUserHelper.Instance.GetTestUserId();
		if (GameBootConfig.readOnlyInstance.mCSharpVersionConfig != null && GameBootConfig.readOnlyInstance.mCSharpVersionConfig.testUsers.Contains(testUserId))
		{
			return true;
		}

		if (GameBootConfig.readOnlyInstance.bOpenDebugTest)
		{
			return true;
		}

		return false;
	}

#if UNITY_EDITOR
	private int nLastThemeTestType = -1;
	private void Update()
	{
		if (m_nThemeTestType != nLastThemeTestType)
		{
			nLastThemeTestType = m_nThemeTestType;
			DoThemeTestChange();
		}
	}

	private void DoThemeTestChange()
	{
		if (LuaMainEnv.readOnlyInstance == null) return;
		var ThemeLoader = LuaMainEnv.Instance.GetLuaClientEnv().Global.GetInPath<LuaTable>("ThemeLoader");
		if (ThemeLoader == null) return;
		string luaThemeKey = ThemeLoader.Get<string>("luaThemeKey");
		if (luaThemeKey == null) return;
		var m_LuaConfigTable = LuaMainEnv.Instance.GetLuaClientEnv().Global.GetInPath<LuaTable>(luaThemeKey + "Config");
		if (m_LuaConfigTable == null) return;
		var InitTestDataFunc = m_LuaConfigTable.GetInPath<LuaFunction>("InitTestData");
		if (InitTestDataFunc == null) return;
		InitTestDataFunc.Call(m_LuaConfigTable);
	}
#endif

}
