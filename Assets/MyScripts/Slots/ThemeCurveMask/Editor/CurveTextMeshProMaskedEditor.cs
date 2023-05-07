using System.Reflection;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(CurveTextMeshProMasked)), CanEditMultipleObjects]
public class CurveTextMeshProMaskedEditor : CurveGroupChildrenEditor
{
    SerializedProperty m_Material;
    CurveTextMeshProMasked mCurveTextMeshProMasked = null;
    SerializedProperty bUseCustomMaterial = null;

    protected override void OnEnable()
    {
        base.OnEnable();

        mCurveTextMeshProMasked = target as CurveTextMeshProMasked;
        m_Material = serializedObject.FindProperty("m_Material");
    }

    public override void OnInspectorGUI()
    {
        serializedObject.Update();
        DrawInspectorGUI();
        serializedObject.ApplyModifiedProperties();

        if (GUI.changed)
        {
            mCurveTextMeshProMasked.GetType().InvokeMember("EditorInit", BindingFlags.Instance | BindingFlags.InvokeMethod | BindingFlags.NonPublic, null, mCurveTextMeshProMasked, new object[] { });
            GUI.changed = false;
        }
    }

    protected override void DrawInspectorGUI()
    {
        base.DrawInspectorGUI();
        EditorGUILayout.PropertyField(m_Material);
    }

}
