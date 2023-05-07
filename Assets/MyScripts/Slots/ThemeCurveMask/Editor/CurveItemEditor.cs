using System.Reflection;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(CurveItem)), CanEditMultipleObjects]
public class CurveItemEditor : CurveGroupChildrenEditor
{
	private CurveItem mCurveItem;
	private SerializedProperty m_color;
	private SerializedProperty m_mainSprite;
	private SerializedProperty m_size;
	private SerializedProperty m_sortingLayerName;
	private SerializedProperty m_sortingOrder;
	private SerializedProperty blendOption;
	private SerializedProperty m_material;

	protected override void OnEnable()
	{
		base.OnEnable();

		mCurveItem = target as CurveItem;
		m_color = serializedObject.FindProperty("m_color");
		m_mainSprite = serializedObject.FindProperty("m_mainSprite");
		m_size = serializedObject.FindProperty("m_size");
		m_sortingLayerName = serializedObject.FindProperty("m_sortingLayerName");
		m_sortingOrder = serializedObject.FindProperty("m_sortingOrder");
		blendOption = serializedObject.FindProperty("blendOption");
		m_material = serializedObject.FindProperty("m_material");
	}

	public override void OnInspectorGUI()
	{
		serializedObject.Update();
		DrawInspectorGUI();
		serializedObject.ApplyModifiedProperties();
		
		if (GUI.changed)
		{
			mCurveItem.Build();
			GUI.changed = false;
		}
	}

	protected override void DrawInspectorGUI()
	{
		base.DrawInspectorGUI();
		EditorGUILayout.PropertyField(m_color);
		EditorGUILayout.PropertyField(m_mainSprite);
		EditorGUILayout.PropertyField(m_material);
		EditorGUILayout.PropertyField(m_size);
		EditorGUILayout.PropertyField(m_sortingLayerName);
		EditorGUILayout.PropertyField(m_sortingOrder);
		EditorGUILayout.PropertyField(blendOption);

		if (mCurveItem.m_mainSprite != null)
		{
			GUILayout.Space(20);
			if (GUILayout.Button("Set Native Size"))
			{
				float w = mCurveItem.m_mainSprite.rect.width;
				float h = mCurveItem.m_mainSprite.rect.height;
				mCurveItem.m_size = new Vector2(w, h);
			}
		}
	}
}
