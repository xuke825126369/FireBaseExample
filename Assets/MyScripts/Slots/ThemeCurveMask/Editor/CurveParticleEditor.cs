using UnityEngine;
using UnityEditor;
using System.Reflection;

/// <summary>
/// Editor class used to edit UI Graphics.
/// Extend this class to write your own graphic editor.
/// </summary>

[CustomEditor(typeof(CurveParticle), true)]
[CanEditMultipleObjects]
public class CurveParticleEditor : CurveGroupChildrenEditor
{
    SerializedProperty m_sprite;
    SerializedProperty m_color;
    SerializedProperty blendOption;
    SerializedProperty m_material;

    CurveParticle mCurveParticle = null;
    private bool bUseCustomMaterial = false;
    
    protected override void OnEnable()
    {
        base.OnEnable();

        m_sprite = serializedObject.FindProperty("m_sprite");
        m_color = serializedObject.FindProperty("m_color");
        blendOption = serializedObject.FindProperty("blendOption");
        m_material = serializedObject.FindProperty("m_material");

        mCurveParticle = target as CurveParticle;
        bUseCustomMaterial = m_material.objectReferenceValue;
    }

    public override void OnInspectorGUI () 
    {
        serializedObject.Update();
        
        DrawInspectorGUI();

        serializedObject.ApplyModifiedProperties();

        if (GUI.changed)
        {
            mCurveParticle.Build();
            GUI.changed = false;
        }
    }

    protected override void DrawInspectorGUI()
    {
        base.DrawInspectorGUI();
        bUseCustomMaterial = EditorGUILayout.Toggle("Use Custom Material", bUseCustomMaterial);
        
        if (bUseCustomMaterial)
        {
            m_sprite.objectReferenceValue = null;
            EditorGUILayout.PropertyField(m_material);
        }
        else
        {
            m_material.objectReferenceValue = null;
            EditorGUILayout.PropertyField(m_sprite);
            EditorGUILayout.PropertyField(m_color);
            EditorGUILayout.PropertyField(blendOption);
        }
    }

}
