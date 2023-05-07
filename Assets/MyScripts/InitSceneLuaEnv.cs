using System;
using System.Collections;
using System.IO;
using System.Text;
using UnityEngine;
using XLua;

[XLua.LuaCallCSharp]
public class InitSceneLuaEnv : SingleTonMonoBehaviour<InitSceneLuaEnv>
{
	private static LuaEnv luaEnv = null;

	public void Init()
	{
		luaEnv = new LuaEnv();
		InitLuaLoader(luaEnv);
	}

	public LuaEnv GetEnv()
	{
		return luaEnv;
	}

	float lastGCTime = 0f;
	void Update()
	{
		if (Time.time - lastGCTime > 60)
		{
			luaEnv.Tick();
			lastGCTime = Time.time;
		}
	}

	private void DestroyLuaEnv()
	{
        try
		{
			luaEnv.Dispose();
            Debug.Log("DestroyLuaEnv------------------------------------------------");
		}
		catch (Exception e)
		{
			Debug.LogError(e.Message + " | " + e.StackTrace);
			DebugLuaFuncRefByCsharp();
		}

        luaEnv = null;
    }

    protected override void OnDestroy()
	{
		base.OnDestroy();
		DestroyLuaEnv();
    }

	private void DebugLuaFuncRefByCsharp()
    {
		luaEnv.DoString("local helper = require \"xlua.util\" helper.print_func_ref_by_csharp()");
	}

	private void InitLuaLoader(LuaEnv mLuaEnv)
	{
		mLuaEnv.AddLoader((ref string filename) =>
		{
            string bundleName = GameBootConfig.mInitSceneBundleName;
            if (GameConfig.Instance.orUseAssetBundle)
            {
                if (!AssetBundleManager.Instance.ContainsBundle(bundleName))
                {
                    return null;
                }
            }

            string path = filename.Replace(".", "/");
			if (!path.EndsWith(".lua.txt"))
			{
				path += ".lua.txt";
			}

            path = Path.Combine("Assets/ResourceABs/InitScene/", path);
            if (AssetBundleManager.Instance.ContainsAsset(bundleName, path))
			{
				UnityEngine.Object mObj = AssetBundleManager.Instance.LoadAsset(bundleName, path);
				TextAsset mLuaFile = mObj as TextAsset;
				string content = mLuaFile.text;
				string data = LuaParser.Decode(content);
				return Encoding.UTF8.GetBytes(data);
			}
			else
			{
				Debug.Log(filename + " Require 失败: " + path);
				return null;
			}
		});
	}
	
	public IEnumerator LoadInitScene()
	{
		string bundleName = GameBootConfig.mInitSceneBundleName;
		if (GameConfig.Instance.orUseAssetBundle)
		{
			bool bCache = false;

			if (GameBootConfig.Instance.mOldWebAssetBundleHotUpdateConfig != null && GameBootConfig.Instance.mOldWebAssetBundleHotUpdateConfig.nCSharpVersion == Application.version && GameBootConfig.Instance.mOldWebAssetBundleHotUpdateConfig.mInitSceneWebItemDic.ContainsKey(bundleName))
			{
				AssetBundleHotUpdateConfig.AssetBundleHotUpdateItem mItem = GameBootConfig.Instance.mOldWebAssetBundleHotUpdateConfig.mInitSceneWebItemDic[bundleName];
				bCache = mItem.IsVersionCached();
				if (bCache)
				{
					yield return AssetBundleManager.Instance.AsyncLoadWebBundle(mItem);
					Debug.Log("LoadInitScene In WebCache ");
				}
			}
			else
			{
				Debug.Log("AssetBundleConfig.Instance.mOldWebBundleConfig is NUll ");
			}

			if (!bCache)
			{
				AssetBundleHotUpdateConfig mConfig = GameBootConfig.Instance.mResourcesAssetBundleHotUpdateConfig;
				var mItem = mConfig.GetHotUpdateItem(mConfig.mInitSceneWebItemDic, bundleName);
				yield return AssetBundleManager.Instance.AsyncLoadLocalBundle(GameBootConfig.Instance.LocalStreamingAssetsBundlePathRoot, mItem);
				Debug.Log("LoadInitScene In LocalStreamCache ");
			}
		}

		luaEnv.DoString("require 'Lua/InitScene'", bundleName);
	}

}
