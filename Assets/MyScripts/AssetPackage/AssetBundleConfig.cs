using System.Collections.Generic;
using System.IO;
using UnityEngine;

[XLua.LuaCallCSharp]
public class AssetBundleHotUpdateConfig
{
	public class AssetBundleHotUpdateItem
	{
		public string bundleName;
		public string mHash;
		public string bundleNameWithHash;
		public bool bUpdate;

		public Hash128 GetHash128()
		{
			return Hash128.Parse(mHash);
		}

		public string GetBundleFileName()
		{
			return bundleName + "_" + mHash;
		}

		public string GetUrl()
		{
			if (StreamingAssetsBundlePathDir.orExistFile(bundleNameWithHash))
			{
				return GetStreamingAssetsUrl();
			}
			else
			{
				return GetWebUrl();
			}
		}

		private string GetWebUrl()
		{
			string url = Path.Combine(GameBootConfig.Instance.ResUrlRoot, bundleNameWithHash);
			return url;
		}

		private string GetStreamingAssetsUrl()
		{
			string url = Path.Combine(GameBootConfig.Instance.LocalStreamingAssetsBundleWebUrlRoot, bundleNameWithHash);
			return url;
		}

		public bool IsVersionCached()
		{
			return Caching.IsVersionCached(GetWebUrl(), GetHash128()) || StreamingAssetsBundlePathDir.orExistFile(bundleNameWithHash);
		}
	}

	public string nCSharpVersion;
	public Dictionary<string, AssetBundleHotUpdateItem> mInitSceneWebItemDic = new Dictionary<string, AssetBundleHotUpdateItem>();
    public Dictionary<string, AssetBundleHotUpdateItem> mActivityWebItemDic = new Dictionary<string, AssetBundleHotUpdateItem>();
    public Dictionary<string, AssetBundleHotUpdateItem> mThemeWebItemDic = new Dictionary<string, AssetBundleHotUpdateItem>();

	public AssetBundleHotUpdateItem GetHotUpdateItem(Dictionary<string, AssetBundleHotUpdateItem> mDic, string bundleName)
	{
		bundleName = bundleName.ToLower();
		AssetBundleHotUpdateItem mItem = null;
		mDic.TryGetValue(bundleName, out mItem);
		return mItem;
	}
}

[XLua.LuaCallCSharp]
public class AssetBundleConfig : Singleton<AssetBundleConfig>
{
    public AssetBundleHotUpdateConfig mAssetBundleHotUpdateConfig = null;
}
