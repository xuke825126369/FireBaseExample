using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

public static class ABBuildConfigEditor
{
	public const BuildAssetBundleOptions mBuildAssetBundleOptions = BuildAssetBundleOptions.AppendHashToAssetBundleName;

	public static List<string> GetInitLoadedBundleDirList()
	{
		List<string> mDirPathList = new List<string>();
		mDirPathList.Add("Assets/ResourceABs/InitScene");
		mDirPathList.Add("Assets/ResourceABs/Global");
		mDirPathList.Add("Assets/ResourceABs/Lobby");
		mDirPathList.Add("Assets/ResourceABs/Lua");
		mDirPathList.Add("Assets/ResourceABs/ThemeVideoCommon");
        mDirPathList.Add("Assets/ResourceABs/ActivityCommon");
        return mDirPathList;
	}

    public static List<string> GetActivityBundleDirList()
    {
        List<string> mDirPathList = new List<string>();
        var DirList = Directory.GetDirectories("Assets/ResourceABs/Activity/");
        foreach (var v in DirList)
        {
            mDirPathList.Add(v);
        }
        return mDirPathList;
    }

    public static List<string> GetThemeDependBundleDirList()
	{
		List<string> mDirPathList = new List<string>();
		mDirPathList.Add("Assets/ResourceABs/Global/");
		mDirPathList.Add("Assets/ResourceABs/Lobby/");
		mDirPathList.Add("Assets/ResourceABs/ThemeVideoCommon/");
		return mDirPathList;
	}

	public static List<string> GetLuaBundleDirList()
	{
		List<string> mDirPathList = new List<string>();
		mDirPathList.Add("Assets/ResourceABs/Lua");
		return mDirPathList;
	}

	public static List<string> GetInitSceneBundleDirList()
	{
		List<string> mDirPathList = new List<string>();
		mDirPathList.Add("Assets/ResourceABs/InitScene");
		return mDirPathList;
	}

	public static List<string> GetThemeAllBundleDirList()
	{
		List<string> mDirPathList = new List<string>();
		var DirList = Directory.GetDirectories("Assets/ResourceABs/ThemeVideoEntry/");
		foreach (var v in DirList)
		{
			mDirPathList.Add(v);
		}

		DirList = Directory.GetDirectories("Assets/ResourceABs/ThemeVideoSlot/");
		foreach (var v in DirList)
		{
			mDirPathList.Add(v);
		}

		return mDirPathList;
	}

    public static List<string> GetNeedCopyBundleToStreamingAssetsList()
    {
        List<string> mBundleNameList = new List<string>();
        mBundleNameList.Add("InitScene");
        mBundleNameList.Add("themevideoslot_redhat");
        mBundleNameList.Add("themevideoentry_redhat");
        return mBundleNameList;
    }

    public static string getOutPath()
	{
		string targetOutAssetPath = $"Assets/AAABuild/{GetBuildTargetPlatformName()}/";
		return targetOutAssetPath;
	}

	public static string GetLocalWebTestPath()
	{
		return "Assets/AAALocalWebTest/" + GetBuildTargetPlatformName() + "/";
	}

    public static string GetStreamingAssetsBundlePathRoot()
    {
        return Application.streamingAssetsPath + "/LocalWeb/";
    }

    private static string GetLocalWebTestFullPathByBundleName(string bundleName)
	{
		bundleName = bundleName.ToLower();
		string dir = GetLocalWebTestPath();
		foreach (var v in Directory.GetFiles(dir))
		{
			if (!v.Contains(".meta") && !v.Contains(".manifest") && v.ToLower().Contains(bundleName))
			{
				return v;
			}
		}

		return null;
	}

	private static void DeleteStreamingAssetsSameBundleNameFile(string pathPreifx)
	{
        pathPreifx = pathPreifx.ToLower();
        string dir = GetStreamingAssetsBundlePathRoot();
        if (!Directory.Exists(dir))
        {
            Directory.CreateDirectory(dir);
        }

        List<string> mPrefixList = new List<string>();
		foreach (string v in Directory.GetFiles(dir))
		{
			if (v.Contains(pathPreifx))
			{
				mPrefixList.Add(v);
			}
		}

		foreach (var v in mPrefixList)
		{
			File.Delete(v);
		}
	}

	public static void CopyBundleToStreamingAssets(string bundleName)
	{
		bundleName = bundleName.ToLower();
		DeleteStreamingAssetsSameBundleNameFile(bundleName);
		string oriFilePath = GetLocalWebTestFullPathByBundleName(bundleName);
		string oriFileName = Path.GetFileName(oriFilePath);
		if (!string.IsNullOrWhiteSpace(oriFilePath))
		{
			string targetOutAssetPathDir = GetStreamingAssetsBundlePathRoot();
			string targetOutAssetPath = targetOutAssetPathDir + oriFileName;
            if (!Directory.Exists(targetOutAssetPathDir))
            {
                Directory.CreateDirectory(targetOutAssetPathDir);
            }

            File.Copy(oriFilePath, targetOutAssetPath, true);
		}
		else
		{
			Debug.LogError("CopyBundleToStreamingAssets Error: " + bundleName);
		}
	}

    private static void DeleteLocalWebTestOriSameBundleNameFile(string pathPreifx)
	{
        pathPreifx = pathPreifx.ToLower();
        string localWebTestDir = GetLocalWebTestPath();
		List<string> mPrefixList = new List<string>();
		foreach (string v in Directory.GetFiles(localWebTestDir))
		{
			if (v.Contains(pathPreifx))
			{
				mPrefixList.Add(v);
			}
		}

		foreach (var v in mPrefixList)
		{
			File.Delete(v);
		}
	}

	public static void CopyBuildBundleToLocalWebTestPath()
    {
		string oriDir = getOutPath();
		string localWebTestDir = GetLocalWebTestPath();
		if (!Directory.Exists(localWebTestDir))
		{
			Directory.CreateDirectory(localWebTestDir);
		}

		foreach (string v in Directory.GetFiles(oriDir))
		{
			if (!v.EndsWith(".meta") && !v.EndsWith(".manifest"))
			{
				string fileName = Path.GetFileName(v);
				int nLastIndex = fileName.LastIndexOf("_");
				if (nLastIndex > 0)
				{
					string pathPreifx = fileName.Substring(0, nLastIndex);
					DeleteLocalWebTestOriSameBundleNameFile(pathPreifx);
				}
				File.Copy(v, localWebTestDir + fileName, true);
			}
		}
	}

	public static string GetBuildTargetPlatformName()
    {
		return GetBuildTarget().ToString();
    }

	public static BuildTarget GetBuildTarget()
	{
		BuildTarget target = BuildTarget.StandaloneWindows64;

#if UNITY_IPHONE
		target = BuildTarget.iOS;
#elif UNITY_ANDROID
		target = BuildTarget.Android;
#endif
		return target;
	}
	
	public static void ClearFolder()
	{
		string targetOutAssetPath = ABBuildConfigEditor.getOutPath();
		if (!Directory.Exists(targetOutAssetPath))
		{
			Directory.CreateDirectory(targetOutAssetPath);
		}

		string path = targetOutAssetPath;
		DirectoryInfo mdir = new DirectoryInfo(path);
		foreach (FileInfo f in mdir.GetFiles())
		{
			f.Delete();
		}

		foreach (DirectoryInfo f in mdir.GetDirectories())
		{
			f.Delete(true);
		}

		AssetDatabase.SaveAssets();
		AssetDatabase.Refresh();
	}

	public static string GetBundleNameByDirPath(string dirPath)
	{
		string[] dirArray = dirPath.Split('/');
		string lastDirName = string.Empty;
		string lastSecondDirName = string.Empty;
		if (dirPath.EndsWith("/"))
		{
			lastDirName = dirArray[dirArray.Length - 2];
			lastSecondDirName = dirArray[dirArray.Length - 3];
		}
		else
		{
			lastDirName = dirArray[dirArray.Length - 1];
			lastSecondDirName = dirArray[dirArray.Length - 2];
		}

		if (lastSecondDirName.ToLower() == "ResourceABs".ToLower())
		{
            string bundleName = lastDirName.ToLower();
            return bundleName.ToLower();
        }
		else
		{
			string bundleName = (lastSecondDirName + "_" + lastDirName).ToLower();
			return bundleName.ToLower();
		}
	}

	public static string GetThemeNameByDirPath(string dirPath)
	{
		string[] dirArray = dirPath.Split('/');
		string lastDirName = string.Empty;
		if (dirPath.EndsWith("/"))
		{
			lastDirName = dirArray[dirArray.Length - 2];
		}
		else
		{
			lastDirName = dirArray[dirArray.Length - 1];
		}
		return lastDirName;
	}
}
