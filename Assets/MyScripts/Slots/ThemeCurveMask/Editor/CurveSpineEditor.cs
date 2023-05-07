using UnityEditor;
using UnityEngine;

[CustomEditor (typeof (CurveSpine)), CanEditMultipleObjects] 
public class CurveSpineEditor : CurveGroupChildrenEditor
{
	private CurveSpine mCurveSpine;
	private SerializedProperty m_color;
	private SerializedProperty m_sortingLayerName;
	private SerializedProperty m_sortingOrder;

    protected override void OnEnable()
    {
        base.OnEnable();

		mCurveSpine = target as CurveSpine;
		m_color = serializedObject.FindProperty("m_color");
		m_sortingLayerName = serializedObject.FindProperty("m_sortingLayerName");
		m_sortingOrder = serializedObject.FindProperty("m_sortingOrder");
	}

    public override void OnInspectorGUI ()
	{
		serializedObject.Update();
		DrawInspectorGUI();
		serializedObject.ApplyModifiedProperties();
		
		if (GUI.changed){
			mCurveSpine.Build();
			GUI.changed = false;
		}
	}

	protected override void DrawInspectorGUI()
	{
		base.DrawInspectorGUI();
		EditorGUILayout.PropertyField(m_color);
		EditorGUILayout.PropertyField(m_sortingLayerName);
		EditorGUILayout.PropertyField(m_sortingOrder);
	}
}