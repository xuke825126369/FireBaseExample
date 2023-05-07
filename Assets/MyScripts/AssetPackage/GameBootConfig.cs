using System.Collections;
using System.Collections.Generic;
using Newtonsoft.Json;
using UnityEngine;

[XLua.LuaCallCSharp]
public class CSharpVersionConfig
{
	public List<string> versionList;
	public List<string> testUsers;
}

[XLua.LuaCallCSharp]
public class GameBootConfig : Singleton<GameBootConfig>
{
	public string LocalStreamingAssetsBundlePathRoot = string.Empty;
	public string LocalStreamingAssetsBundleWebUrlRoot = string.Empty;
	public AssetBundleHotUpdateConfig mOldWebAssetBundleHotUpdateConfig = null;
    public AssetBundleHotUpdateConfig mResourcesAssetBundleHotUpdateConfig = null;
    public const string mInitSceneBundleName = "initscene";

	public const string mCSharpVersionConfigFileName = "CSharpVersionConfig.json";
	public const string mHotUpdateConfigDBName = "HotUpdateConfig.json.db";
	public const string mHotUpdateConfigFileName = "AssetBundleHotUpdateConfig.json";
	
	public string CSharpVersionWebUrl = string.Empty;
	public string WebUrlRoot = string.Empty;
	public string ResUrlRoot = string.Empty;
    public CSharpVersionConfig mCSharpVersionConfig = null;
	public string mTestUserId = string.Empty;
	public bool bOpenDebugTest = false;

	public void Init()
	{
        InitResourcesAssetBundleHotUpdateConfig();
        InitOldWebAssetBundleHotUpdateConfig();

        LocalStreamingAssetsBundlePathRoot = Application.streamingAssetsPath + "/LocalWeb/";
        LocalStreamingAssetsBundleWebUrlRoot = getStreamingAssetsPathUrl("LocalWeb/");

		if (Application.platform == RuntimePlatform.Android)
		{
			WebUrlRoot = GameConfig.WebUrlRoot;
			CSharpVersionWebUrl = WebUrlRoot + mCSharpVersionConfigFileName;
		}
		else if (Application.platform == RuntimePlatform.IPhonePlayer)
		{
            WebUrlRoot = GameConfig.WebUrlRoot;
            CSharpVersionWebUrl = WebUrlRoot + mCSharpVersionConfigFileName;
		}
		else
		{
			CSharpVersionWebUrl = $"file:///{Application.dataPath}/Resources/" + mCSharpVersionConfigFileName;
#if UNITY_ANDROID
			WebUrlRoot = $"file:///{Application.dataPath}/AAALocalWebTest/Android/";
#elif UNITY_IOS
			WebUrlRoot = $"file:///{Application.dataPath}/AAALocalWebTest/IOS/";
#endif
		}

#if UNITY_EDITOR
        ResUrlRoot = WebUrlRoot;
#else
		ResUrlRoot = WebUrlRoot + Application.version + "/";
		Debug.Log("ResUrlRoot: " + ResUrlRoot);
#endif

        mTestUserId = TestUserHelper.Instance.GetTestUserId();
		Debug.Log("mTestUserId: " + mTestUserId);
		Debug.Log("Platform: " + Application.platform);
		Debug.Log("RemoteWebUrlRoot: " + WebUrlRoot);
		Debug.Log("LocalBundlePath: " + LocalStreamingAssetsBundlePathRoot);
		Debug.Log("LocalWebUrlRoot: " + LocalStreamingAssetsBundleWebUrlRoot);
		Debug.Log("CSharpVersionWebUrl: " + CSharpVersionWebUrl);
	}

	private void InitResourcesAssetBundleHotUpdateConfig()
	{
		TextAsset mTextAsset = null;
#if UNITY_IOS
		mTextAsset = Resources.Load<TextAsset>("AssetBundleHotUpdateConfig_IOS");
#else
		mTextAsset = Resources.Load<TextAsset>("AssetBundleHotUpdateConfig_Android");
#endif
		mResourcesAssetBundleHotUpdateConfig = Newtonsoft.Json.JsonConvert.DeserializeObject<AssetBundleHotUpdateConfig>(mTextAsset.text);
	}

	private void InitOldWebAssetBundleHotUpdateConfig()
	{
		mOldWebAssetBundleHotUpdateConfig = null;
		if (PlayerPrefs.HasKey(mHotUpdateConfigDBName))
		{
			string jsonStr = PlayerPrefs.GetString(mHotUpdateConfigDBName);
			mOldWebAssetBundleHotUpdateConfig = JsonConvert.DeserializeObject<AssetBundleHotUpdateConfig>(jsonStr);
		}
	}


    public string getStreamingAssetsPathUrl(string relativePath)
	{
		string url = "";
		if (Application.platform == RuntimePlatform.Android)
		{
			url = Application.streamingAssetsPath + "/" + relativePath;
		}
		else
		{
			url = "file:///" + Application.streamingAssetsPath + "/" + relativePath;
		}

		return url;
	}
}
