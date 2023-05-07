using System.Collections.Generic;
using System.IO;
using System.Reflection;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(ThemeBuild)), CanEditMultipleObjects]
public class ThemeBuildEditor : Editor
{
	private ThemeBuild mThemeBuild;
	private void OnEnable()
	{
		mThemeBuild = target as ThemeBuild;
		foreach (var v in Directory.GetDirectories("Assets/ResourceABs/ThemeVideoSlot/"))
		{
			var themeName = ABBuildConfigEditor.GetThemeNameByDirPath(v);
			ThemeBuild.BuildItem mItem = mThemeBuild.m_BuildThemeVideoList.Find((x) => x.themeName == themeName);
			if (mItem == null)
			{
				mItem = new ThemeBuild.BuildItem();
				mItem.themeName = themeName;
				mItem.m_bSelect = false;
				mThemeBuild.m_BuildThemeVideoList.Add(mItem);
			}
		}

		var mShouldRemoveList = new List<string>();
		foreach (var buildItem in mThemeBuild.m_BuildThemeVideoList)
		{
			bool bFind = false;
			foreach (var v in Directory.GetDirectories("Assets/ResourceABs/ThemeVideoSlot/"))
			{
				var themeName = ABBuildConfigEditor.GetThemeNameByDirPath(v);
				if (themeName == buildItem.themeName)
				{
					bFind = true;
					break;
				}
			}

			if (!bFind)
			{
				mShouldRemoveList.Add(buildItem.themeName);
			}
		}

		foreach (var v in mShouldRemoveList)
		{
			mThemeBuild.m_BuildThemeVideoList.RemoveAll((x) => x.themeName == v);
		}


	}

	public override void OnInspectorGUI()
	{
		serializedObject.Update();
		DrawThemeListInspector();

		GUILayout.Space(20);
        if (GUILayout.Button("Build"))
        {
            DoBuild();
        }
        serializedObject.ApplyModifiedProperties();
	}
	
	private void DrawThemeListInspector()
	{
		GUILayout.BeginHorizontal();
		if (GUILayout.Button("全部选择", GUILayout.MaxWidth(100)))
		{
			foreach (var v in mThemeBuild.m_BuildThemeVideoList)
			{
				v.m_bSelect = true;
			}
		}
		if (GUILayout.Button("取消所有选择", GUILayout.MaxWidth(100)))
		{
			foreach (var v in mThemeBuild.m_BuildThemeVideoList)
			{
				v.m_bSelect = false;
			}
		}
		GUILayout.EndHorizontal();
		GUILayout.Space(10);

		foreach (var v in mThemeBuild.m_BuildThemeVideoList)
		{
			GUILayout.BeginHorizontal();
			v.m_bSelect = EditorGUILayout.ToggleLeft(v.themeName, v.m_bSelect);
			GUILayout.EndHorizontal();
		}
	}

	private void DoBuild()
	{
		ABBuildConfigEditor.ClearFolder();

		List<AssetBundleBuild> assetBundleBuildList = new List<AssetBundleBuild>();
		foreach (var v in ABBuildConfigEditor.GetThemeDependBundleDirList())
		{
			string dirPath = v;
			string[] allFiles = Directory.GetFiles(dirPath, "*", SearchOption.AllDirectories);
			AssetBundleBuild mAssetBundleBuild = new AssetBundleBuild();
			mAssetBundleBuild.assetBundleName = ABBuildConfigEditor.GetBundleNameByDirPath(dirPath);
			mAssetBundleBuild.assetNames = allFiles;
			assetBundleBuildList.Add(mAssetBundleBuild);
		}

		List<string> dirPathList = new List<string>();
		foreach (var v in mThemeBuild.m_BuildThemeVideoList)
		{
			if (v.m_bSelect)
			{
				dirPathList.Add("Assets/ResourceABs/ThemeVideoSlot/" + v.themeName);
                dirPathList.Add("Assets/ResourceABs/ThemeVideoEntry/" + v.themeName);
            }
		}

        foreach (var dirPath in dirPathList)
		{
			string[] allFiles = Directory.GetFiles(dirPath, "*", SearchOption.AllDirectories);
			AssetBundleBuild mAssetBundleBuild = new AssetBundleBuild();
			mAssetBundleBuild.assetBundleName = ABBuildConfigEditor.GetBundleNameByDirPath(dirPath);
			mAssetBundleBuild.assetNames = allFiles;
			assetBundleBuildList.Add(mAssetBundleBuild);
		}

		var mAssetBundleManifest = BuildPipeline.BuildAssetBundles(ABBuildConfigEditor.getOutPath(), assetBundleBuildList.ToArray(), ABBuildConfigEditor.mBuildAssetBundleOptions, ABBuildConfigEditor.GetBuildTarget());
		UpdateHotUpdateConfigEditor.Build(mAssetBundleManifest);
		ABBuildConfigEditor.CopyBuildBundleToLocalWebTestPath();
		AssetDatabase.SaveAssets();
		AssetDatabase.Refresh();

		ExportBuildEditor.CopyBundleToStreamingAssets();
	}
}

