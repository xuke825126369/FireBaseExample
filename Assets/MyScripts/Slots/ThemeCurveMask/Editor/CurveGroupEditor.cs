using System.Collections.Generic;
using System.Reflection;
using UnityEditor;
using UnityEngine;

[CustomEditor (typeof (CurveGroup)), CanEditMultipleObjects] 
public class CurveGroupEditor : Editor
{
	private CurveGroup mCurveGroup;

    private void OnEnable()
    {
		mCurveGroup = target as CurveGroup;
	}

	public override void OnInspectorGUI()
	{
		serializedObject.Update();

		base.DrawDefaultInspector();
		var mChildrenListFieldInfo = mCurveGroup.GetType().GetField("mChildrenList", BindingFlags.Instance | BindingFlags.GetField | BindingFlags.NonPublic);
		if (mChildrenListFieldInfo != null)
		{
			var mChildrenList = mChildrenListFieldInfo.GetValue(mCurveGroup) as List<CurveGroupChildren>;
			EditorGUILayout.LabelField("mChildrenList: " + mChildrenList.Count);
			for (int i = 0; i < mChildrenList.Count; ++i)
			{
				if (mChildrenList[i])
				{
					EditorGUILayout.ObjectField("", mChildrenList[i].gameObject, typeof(GameObject), false);
				}
			}
		}

		serializedObject.ApplyModifiedProperties();
	}

	void OnSceneGUI()
	{
		CurveGroup group = target as CurveGroup;
		Vector3 center = group.transform.position;
		float halfWidth = group.m_areaSize.x / 2;
		float halfHeight = group.m_areaSize.y / 2;
		Vector3 lb = center + new Vector3 (-halfWidth, -halfHeight, 0);
		Vector3 rb = center + new Vector3 (halfWidth, -halfHeight, 0);
		Vector3 rt = center + new Vector3 (halfWidth, halfHeight, 0);
		Vector3 lt = center + new Vector3 (-halfWidth, halfHeight, 0);
		Handles.DrawLine(lb, rb);
		Handles.DrawLine(rb, rt);
		Handles.DrawLine(rt, lt);
		Handles.DrawLine(lt, lb);
		Handles.color = Color.green;
		Handles.DrawLine(lb, rt);
		Handles.DrawLine(lt, rb);
	}
}

