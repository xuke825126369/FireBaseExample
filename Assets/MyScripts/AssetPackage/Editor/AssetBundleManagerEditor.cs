using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Reflection;

[CustomEditor(typeof(AssetBundleManager)), CanEditMultipleObjects]
public class AssetBundleManagerEditor : Editor
{
	private AssetBundleManager mAssetBundleManager;
	private void OnEnable()
	{
		mAssetBundleManager = target as AssetBundleManager;
	}

	public override void OnInspectorGUI()
	{
		serializedObject.Update();
		base.DrawDefaultInspector();
		DrawCustomInspectorGUI();
		serializedObject.ApplyModifiedProperties();
	}

	private void DrawCustomInspectorGUI()
	{
		var mChildrenListFieldInfo = mAssetBundleManager.GetType().GetField("mBundleDic", BindingFlags.Instance | BindingFlags.GetField | BindingFlags.NonPublic);
		if (mChildrenListFieldInfo != null)
		{
			var mChildrenList = mChildrenListFieldInfo.GetValue(mAssetBundleManager) as Dictionary<string, AssetBundle>;
			EditorGUILayout.LabelField("BundleList: " + mChildrenList.Count);
			foreach (var v in mChildrenList)
			{

				EditorGUILayout.LabelField(v.Key);
				EditorGUILayout.ObjectField(v.Value, typeof(AssetBundle));
			}
		}
	}
}
