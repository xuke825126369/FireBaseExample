using System.Reflection;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(CurveTextMeshFontMasked)), CanEditMultipleObjects]
public class CurveTextMeshFontMaskedEditor : CurveGroupChildrenEditor
{
    SerializedProperty m_Color;
    SerializedProperty m_Material;
	CurveTextMeshFontMasked mCurveTextMeshFontMasked = null;
	private bool bUseCustomMaterial = false;

	protected override void OnEnable()
	{
		base.OnEnable();

		mCurveTextMeshFontMasked = target as CurveTextMeshFontMasked;
        m_Color = serializedObject.FindProperty("m_Color");
        m_Material = serializedObject.FindProperty("m_Material");
		bUseCustomMaterial = m_Material.objectReferenceValue;
	}

    public override void OnInspectorGUI()
    {
        serializedObject.Update();

        DrawInspectorGUI();

        serializedObject.ApplyModifiedProperties();

        if (GUI.changed)
        {
            mCurveTextMeshFontMasked.GetType().InvokeMember("EditorInit", BindingFlags.Instance | BindingFlags.InvokeMethod | BindingFlags.NonPublic, null, mCurveTextMeshFontMasked, new object[] { });
            GUI.changed = false;
        }
    }

    protected override void DrawInspectorGUI()
    {
        base.DrawInspectorGUI();
        m_Color.colorValue = EditorGUILayout.ColorField("Color", m_Color.colorValue);
        bUseCustomMaterial = EditorGUILayout.Toggle("Use Custom Material", bUseCustomMaterial);

        if (bUseCustomMaterial)
        {
            EditorGUILayout.PropertyField(m_Material);
        }
        else
        {
            m_Material.objectReferenceValue = null;
        }
    }
}
