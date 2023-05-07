using System.Collections;
using System.Collections.Generic;
using System.IO;
using Newtonsoft.Json;
using UnityEngine;

public class UpdateHotUpdateConfigEditor
{
	public static void Build(AssetBundleManifest mAllBundleMainifest = null)
	{
		string targetOutAssetPath = ABBuildConfigEditor.getOutPath();
		string bundleName1 = Path.GetFileName(targetOutAssetPath);
		string path = Path.Combine(targetOutAssetPath, bundleName1);
		if (mAllBundleMainifest == null)
		{
			AssetBundle bundle = AssetBundle.LoadFromFile(path);
			mAllBundleMainifest = bundle.LoadAsset<AssetBundleManifest>("AssetBundleManifest");
			bundle.Unload(true);
		}

		Debug.Assert(mAllBundleMainifest != null, "mAllBundleMainifest == null");
		UpdateHotUpdateConfigInfo(mAllBundleMainifest);
	}
	
	private static void UpdateHotUpdateConfigInfo(AssetBundleManifest mAllBundleMainifest)
	{
		string targetOutAssetPath = ABBuildConfigEditor.getOutPath();
		string savedJsonFileName = "";

#if UNITY_ANDROID
		savedJsonFileName = "AssetBundleHotUpdateConfig_Android.json";
#elif UNITY_IOS
		savedJsonFileName = "AssetBundleHotUpdateConfig_IOS.json";
#endif

		string savePath = Path.Combine("Assets/Resources/", savedJsonFileName);
		AssetBundleHotUpdateConfig mRecord = null;
		if (File.Exists(savePath))
		{
			string jsonStr1 = File.ReadAllText(savePath);
			mRecord = JsonConvert.DeserializeObject<AssetBundleHotUpdateConfig>(jsonStr1);
		}
		else
		{
			mRecord = new AssetBundleHotUpdateConfig();
		}

		List<string> mThemeBundleNameList = GetThemeBundleNameList();
        List<string> mActivityBundleNameList = GetActivityBundleNameList();
        foreach (var v in mAllBundleMainifest.GetAllAssetBundles())
		{
			string[] bundleDependentList = mAllBundleMainifest.GetAllDependencies(v);
			string mHash = mAllBundleMainifest.GetAssetBundleHash(v).ToString();
			int nIndex = v.IndexOf(mHash);
			string bundleName = v.Substring(0, nIndex - 1);

			AssetBundleHotUpdateConfig.AssetBundleHotUpdateItem mRecordItem = null;
			bool bNewAddItem = false;
			if (mThemeBundleNameList.Contains(bundleName))
			{
				CheckThemeDependent(bundleName, bundleDependentList);
				if (!mRecord.mThemeWebItemDic.TryGetValue(bundleName, out mRecordItem))
				{
					mRecordItem = new AssetBundleHotUpdateConfig.AssetBundleHotUpdateItem();
					mRecord.mThemeWebItemDic.Add(bundleName, mRecordItem);
					bNewAddItem = true;
				}
			}
            else if (mActivityBundleNameList.Contains(bundleName))
            {
                if (!mRecord.mActivityWebItemDic.TryGetValue(bundleName, out mRecordItem))
                {
                    mRecordItem = new AssetBundleHotUpdateConfig.AssetBundleHotUpdateItem();
                    mRecord.mActivityWebItemDic.Add(bundleName, mRecordItem);
                    bNewAddItem = true;
                }
            }
            else
			{
				if (!mRecord.mInitSceneWebItemDic.TryGetValue(bundleName, out mRecordItem))
				{
					mRecordItem = new AssetBundleHotUpdateConfig.AssetBundleHotUpdateItem();
					mRecord.mInitSceneWebItemDic.Add(bundleName, mRecordItem);
					bNewAddItem = true;
				}
			}

			mRecordItem.bUpdate = !bNewAddItem && mHash == mRecordItem.mHash ? false : true;
			mRecordItem.bundleName = bundleName;
			mRecordItem.mHash = mHash;
			mRecordItem.bundleNameWithHash = v;
		}

		mRecord.nCSharpVersion = Application.version;
		string jsonStr = JsonConvert.SerializeObject(mRecord);
		jsonStr = JsonHelper.FormatJsonString(jsonStr);
		File.WriteAllText(savePath, jsonStr);
		File.WriteAllText(Path.Combine(targetOutAssetPath, GameBootConfig.mHotUpdateConfigFileName), jsonStr);
	}

	public static List<string> GetThemeBundleNameList()
	{
		List<string> mThemeBundleName = new List<string>();
		foreach (var dirPath in ABBuildConfigEditor.GetThemeAllBundleDirList())
		{
			string bundleName = ABBuildConfigEditor.GetBundleNameByDirPath(dirPath);
			mThemeBundleName.Add(bundleName);
		}

		return mThemeBundleName;
	}

    public static List<string> GetActivityBundleNameList()
    {
        List<string> mBundleName = new List<string>();
        foreach (var dirPath in ABBuildConfigEditor.GetActivityBundleDirList())
        {
            string bundleName = ABBuildConfigEditor.GetBundleNameByDirPath(dirPath);
            mBundleName.Add(bundleName);
        }

        return mBundleName;
    }

    private static void CheckThemeDependent(string bundleName, string[] bundleDependentList)
	{
		Debug.Assert(bundleName.StartsWith("theme"), bundleName);

		List<string> dependBundleList = new List<string> { "global", "lobby" };
		if (bundleName.StartsWith("themeclassic"))
		{
			dependBundleList.Add("themeclassiccommon");
		}
		else
		{
			dependBundleList.Add("themevideocommon");
		}

		bool bHaveError = false;
		foreach (var v in bundleDependentList)
		{
			if (!dependBundleList.Contains(v))
			{
				bHaveError = true;
				break;
			}
		}

		if (bHaveError)
		{
			Debug.LogError("主题依赖问题：" + bundleName);
			foreach (var v in bundleDependentList)
			{
				Debug.Log(v);
			}
		}
	}


}
