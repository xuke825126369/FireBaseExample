using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.IO;
using Newtonsoft.Json;

public class ExportBuildEditor
{
	[MenuItem("UnityEditor/Create Need Folder")]
	static void CreateNeedFolder()
	{
        string targetOutAssetPathDir = Application.streamingAssetsPath + "/LocalWeb/";
        if (!AssetDatabase.IsValidFolder(targetOutAssetPathDir))
        {
            AssetDatabase.CreateFolder(Application.streamingAssetsPath, "LocalWeb");
        }

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
        Debug.Log("Finish Create Need Folder");
    }

    [MenuItem("UnityEditor/Export All Activity Bundle")]
    static void BuildAllActivityBundle()
    {
        ABBuildConfigEditor.ClearFolder();
        BuildTarget target = ABBuildConfigEditor.GetBuildTarget();
        string targetOutAssetPath = ABBuildConfigEditor.getOutPath();

        List<AssetBundleBuild> assetBundleBuildList = new List<AssetBundleBuild>();
        foreach (var v in ABBuildConfigEditor.GetActivityBundleDirList())
        {
            string dirName = v;
            string[] allFiles = Directory.GetFiles(dirName, "*", SearchOption.AllDirectories);
            AssetBundleBuild mAssetBundleBuild = new AssetBundleBuild();
            mAssetBundleBuild.assetBundleName = ABBuildConfigEditor.GetBundleNameByDirPath(dirName);
            mAssetBundleBuild.assetNames = allFiles;
            assetBundleBuildList.Add(mAssetBundleBuild);
        }

        AssetBundleManifest mAssetBundleManifest = BuildPipeline.BuildAssetBundles(targetOutAssetPath, assetBundleBuildList.ToArray(), ABBuildConfigEditor.mBuildAssetBundleOptions, target);
        UpdateHotUpdateConfigEditor.Build(mAssetBundleManifest);
        ABBuildConfigEditor.CopyBuildBundleToLocalWebTestPath();
        CopyBundleToStreamingAssets();
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();

        Debug.Log("Finish Export All Activity Bundle ");
    }

    [MenuItem("UnityEditor/Export InitLoaded Bundle")]
	static void BuildInitLoadedBundle()
	{
		ABBuildConfigEditor.ClearFolder();
		LuaCopyEditor.CopyLua();
		BuildTarget target = ABBuildConfigEditor.GetBuildTarget();
		string targetOutAssetPath = ABBuildConfigEditor.getOutPath();

		List<AssetBundleBuild> assetBundleBuildList = new List<AssetBundleBuild>();
		foreach (var v in ABBuildConfigEditor.GetInitLoadedBundleDirList())
		{
			string dirName = v;
			string[] allFiles = Directory.GetFiles(dirName, "*", SearchOption.AllDirectories);
			AssetBundleBuild mAssetBundleBuild = new AssetBundleBuild();
			mAssetBundleBuild.assetBundleName = ABBuildConfigEditor.GetBundleNameByDirPath(dirName);
			mAssetBundleBuild.assetNames = allFiles;
			assetBundleBuildList.Add(mAssetBundleBuild);
		}

		AssetBundleManifest mAssetBundleManifest = BuildPipeline.BuildAssetBundles(targetOutAssetPath, assetBundleBuildList.ToArray(), ABBuildConfigEditor.mBuildAssetBundleOptions, target);
		UpdateHotUpdateConfigEditor.Build(mAssetBundleManifest);
		ABBuildConfigEditor.CopyBuildBundleToLocalWebTestPath();
        CopyBundleToStreamingAssets();
        AssetDatabase.SaveAssets();
		AssetDatabase.Refresh();

		Debug.Log("Finish Export InitLoaded Bundle ");
	}

	[MenuItem("UnityEditor/Export Lua Bundle")]
	static void BuildLuaBundle()
	{
		ABBuildConfigEditor.ClearFolder();
		LuaCopyEditor.CopyLua();
		BuildTarget target = ABBuildConfigEditor.GetBuildTarget();
		string targetOutAssetPath = ABBuildConfigEditor.getOutPath();
		List<AssetBundleBuild> assetBundleBuildList = new List<AssetBundleBuild>();
		foreach (var v in ABBuildConfigEditor.GetLuaBundleDirList())
		{
			string dirName = v;
			string[] allFiles = Directory.GetFiles(dirName, "*", SearchOption.AllDirectories);
			AssetBundleBuild mAssetBundleBuild = new AssetBundleBuild();
			mAssetBundleBuild.assetBundleName = ABBuildConfigEditor.GetBundleNameByDirPath(dirName);
			mAssetBundleBuild.assetNames = allFiles;
			assetBundleBuildList.Add(mAssetBundleBuild);
		}

		var mAssetBundleManifest = BuildPipeline.BuildAssetBundles(targetOutAssetPath, assetBundleBuildList.ToArray(), ABBuildConfigEditor.mBuildAssetBundleOptions, target);
		UpdateHotUpdateConfigEditor.Build(mAssetBundleManifest);
		ABBuildConfigEditor.CopyBuildBundleToLocalWebTestPath();
		AssetDatabase.SaveAssets();
		AssetDatabase.Refresh();

		Debug.Log("Finish Export Lua Bundle ");
	}
	
	[MenuItem("UnityEditor/Export InitScene Bundle")]
	static void BuildInitSceneBundle()
	{
		ABBuildConfigEditor.ClearFolder();
		LuaCopyEditor.CopyLua();
		BuildTarget target = ABBuildConfigEditor.GetBuildTarget();
		string targetOutAssetPath = ABBuildConfigEditor.getOutPath();
		List<AssetBundleBuild> assetBundleBuildList = new List<AssetBundleBuild>();
		foreach (var v in ABBuildConfigEditor.GetInitSceneBundleDirList())
		{
			string dirName = v;
			string[] allFiles = Directory.GetFiles(dirName, "*", SearchOption.AllDirectories);
			AssetBundleBuild mAssetBundleBuild = new AssetBundleBuild();
			mAssetBundleBuild.assetBundleName = ABBuildConfigEditor.GetBundleNameByDirPath(dirName);
			mAssetBundleBuild.assetNames = allFiles;
			assetBundleBuildList.Add(mAssetBundleBuild);
		}

		var mAssetBundleManifest = BuildPipeline.BuildAssetBundles(targetOutAssetPath, assetBundleBuildList.ToArray(), ABBuildConfigEditor.mBuildAssetBundleOptions, target);
		UpdateHotUpdateConfigEditor.Build(mAssetBundleManifest);
        ABBuildConfigEditor.CopyBuildBundleToLocalWebTestPath();
		CopyBundleToStreamingAssets();
        AssetDatabase.SaveAssets();
		AssetDatabase.Refresh();

		Debug.Log("Finish Export InitScene Bundle");
	}

	[MenuItem("UnityEditor/Copy Bundle => StreamingAssets")]
	public static void CopyBundleToStreamingAssets()
	{
		List<string> mBundleNameList = ABBuildConfigEditor.GetNeedCopyBundleToStreamingAssetsList();
		foreach (var v in mBundleNameList)
		{
			ABBuildConfigEditor.CopyBundleToStreamingAssets(v);
		}

		GenerateStreamingAssetsBundlePathDir();
		AssetDatabase.SaveAssets();
		AssetDatabase.Refresh();
		Debug.Log("Finish Copy Bundle To StreamingAssets");
	}

	public static void GenerateStreamingAssetsBundlePathDir()
	{
		List<string> mFileNameList = new List<string>();
		foreach (var v in Directory.GetFiles(ABBuildConfigEditor.GetStreamingAssetsBundlePathRoot()))
		{
			if (!v.Contains(".meta") && !v.Contains(".manifest"))
			{
				mFileNameList.Add(Path.GetFileName(v));
			}
		}

		string codeStr = "using System.Collections;\n";
		codeStr += "using System.Collections.Generic;\n";
		codeStr += "using UnityEngine;\n\n";
		codeStr += "[XLua.LuaCallCSharp]\n";
        codeStr += "public static class StreamingAssetsBundlePathDir\n{\n";
		codeStr += "	private static List<string> mBundleNameList = new List<string>()\n    {\n";
		foreach (var v in mFileNameList)
		{
			codeStr += "		\""+ v.ToLower() + "\",\n";
		}
        codeStr += "	};\n\n";
        codeStr += "\tpublic static bool orExistFile(string subfilePath)\n\t{\n\t\tsubfilePath = subfilePath.ToLower();\n        return mBundleNameList.Contains(subfilePath);\n\t}\n";
        codeStr += "}\n";

        string targetFileName = Application.dataPath + "/StreamingAssetsBundlePathDir.cs";
		File.WriteAllText(targetFileName, codeStr);

		AssetDatabase.SaveAssets();
		AssetDatabase.Refresh();
	}
}
