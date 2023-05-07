using System;
using System.IO;
using System.Text;
using UnityEngine;
using XLua;

[LuaCallCSharp]
public class LuaMainEnv :SingleTonMonoBehaviour<LuaMainEnv>
{
	private static LuaEnv mLuaClientEnv = null;
	private float lastGCTime = 0.0f;

	public void Init ()
	{
		//------------------------ Client -----------------------
		mLuaClientEnv = new LuaEnv ();
		InitLuaLoader (mLuaClientEnv);

		mLuaClientEnv.AddBuildin ("pb", XLua.LuaDLL.Lua.LoadLuaProtobuf);
		mLuaClientEnv.AddBuildin ("rapidjson", XLua.LuaDLL.Lua.LoadRapidJson);
		mLuaClientEnv.DoString ("require 'Lua.Main'");
		
		LuaTable m_mainTable = mLuaClientEnv.Global.Get<LuaTable> ("Main");
		Action<LuaTable> luaMainInit = m_mainTable.Get<Action<LuaTable>> ("Init");
		luaMainInit (m_mainTable);
	}

	protected override void OnDestroy()
	{
		base.OnDestroy();
		//mLuaClientEnv.Dispose();
		mLuaClientEnv = null;
	}

	public LuaEnv GetLuaClientEnv()
	{
		return mLuaClientEnv;
	}
	
	void Update ()
	{
		if (Time.time - lastGCTime > 60) {
			mLuaClientEnv.Tick ();
			lastGCTime = Time.time;
		}
	}

	public void InitLuaLoader(LuaEnv mLuaEnv)
	{
		mLuaEnv.AddLoader((ref string filename) =>
		{
			string luaPath = filename.Replace(".", "/");

			if (GameConfig.Instance.orUseAssetBundle)
			{
				string path = "Assets/ResourceABs/" + luaPath;
				if (!path.EndsWith(".lua.txt"))
				{
					path += ".lua.txt";
				}

				string bundleName = "Lua";
				if (!AssetBundleManager.Instance.ContainsAsset(bundleName, path))
				{
					if (luaPath.Contains("Lua/Theme"))
					{
						LuaTable ThemeLoader = GetLuaClientEnv().Global.GetInPath<LuaTable>("ThemeLoader");
						LuaTable ThemeHelper = GetLuaClientEnv().Global.GetInPath<LuaTable>("ThemeHelper");
						string themeName = ThemeLoader.GetInPath<string>("themeName");
						LuaFunction GetThemeBundleNameFunc = ThemeLoader.GetInPath<LuaFunction>("GetThemeBundleName");
						bundleName = GetThemeBundleNameFunc.Cast<string>();

						LuaFunction IsClassicThemeFunc = ThemeHelper.GetInPath<LuaFunction>("isClassicLevel");
						bool isClassic = IsClassicThemeFunc.Func<string, bool>(themeName);
						if (isClassic)
						{
							path = "Assets/ResourceABs/ThemeClassicSlot/" + themeName + "/" + luaPath;
						}
						else
						{
							path = "Assets/ResourceABs/ThemeVideoSlot/" + themeName + "/" + luaPath;
						}

						if (!path.EndsWith(".lua.txt"))
						{
							path += ".lua.txt";
						}
					}
					else
					{
						return null;
					}
				}

				UnityEngine.Object mObj = AssetBundleManager.Instance.LoadAsset(bundleName, path);
				if (mObj != null)
				{
					TextAsset mLuaFile = mObj as TextAsset;
					string data = LuaParser.Decode(mLuaFile.text);
					return Encoding.UTF8.GetBytes(data);
				}
			}
			else
			{
				string path = "Assets/" + luaPath;
				if (!path.EndsWith(".lua"))
				{
					path += ".lua";
				}

				if (File.Exists(path))
				{
					string content = File.ReadAllText(path);
					return Encoding.UTF8.GetBytes(content);
				}
			}

			Debug.Log(filename + " Require 失败");
			return null;
		});
	}

}