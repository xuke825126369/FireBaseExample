using UnityEngine;
using UnityEditor;
using System.Reflection;

/// <summary>
/// Editor class used to edit UI Graphics.
/// Extend this class to write your own graphic editor.
/// </summary>

[CustomEditor(typeof(TextMeshFontMasked), true)]
[CanEditMultipleObjects]
public class TextMeshFontMaskedEditor : CustomerRectMaskGroupChildrenEditor
{
    SerializedProperty orUseMaterialBlock;
    SerializedProperty m_Color;

    TextMeshFontMasked mTextMeshFontMasked;
    protected override void OnEnable()
    {
        base.OnEnable();
        orUseMaterialBlock = serializedObject.FindProperty("orUseMaterialBlock");
        m_Color = serializedObject.FindProperty("m_Color");

        mTextMeshFontMasked = target as TextMeshFontMasked;
    }
    
    public override void OnInspectorGUI () 
    {
        serializedObject.Update();
        DrawInspectorGUI();
        serializedObject.ApplyModifiedProperties();
                
        if (GUI.changed)
        {
            mTextMeshFontMasked.GetType().InvokeMember("Init", BindingFlags.Instance | BindingFlags.InvokeMethod | BindingFlags.NonPublic, null, mTextMeshFontMasked, new object[] {});
            GUI.changed = false;
        }
    }

    protected override void DrawInspectorGUI()
    {
        base.DrawInspectorGUI();
        orUseMaterialBlock.boolValue = EditorGUILayout.Toggle("orUseMaterialBlock", orUseMaterialBlock.boolValue);
        m_Color.colorValue = EditorGUILayout.ColorField("Color", m_Color.colorValue);
    }

}
