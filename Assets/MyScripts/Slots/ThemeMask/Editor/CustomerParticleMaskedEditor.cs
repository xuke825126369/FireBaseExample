using UnityEngine;
using UnityEditor;
using System.Reflection;

/// <summary>
/// Editor class used to edit UI Graphics.
/// Extend this class to write your own graphic editor.
/// </summary>

[CustomEditor(typeof(CustomerParticleMasked), true)]
[CanEditMultipleObjects]
public class CustomerParticleMaskedEditor : CustomerRectMaskGroupChildrenEditor
{
    SerializedProperty m_SelfSoftMask;
    SerializedProperty m_Texture;
    SerializedProperty m_CustomMaterial;

    GUIContent m_SelfSoftMaskContent;
    CustomerParticleMasked mCustomerParticleMasked = null;
    private bool bUseCustomMaterial = false;

    protected override void OnEnable()
    {
        base.OnEnable();

        m_SelfSoftMaskContent = new GUIContent("Soft Mask");
        
        m_SelfSoftMask = serializedObject.FindProperty("m_SelfSoftMask");
        m_Texture = serializedObject.FindProperty("m_Texture");
        m_CustomMaterial = serializedObject.FindProperty("m_CustomMaterial");
            
        mCustomerParticleMasked = target as CustomerParticleMasked;
        bUseCustomMaterial = m_CustomMaterial.objectReferenceValue;
    }

    public override void OnInspectorGUI () 
    {
        serializedObject.Update();
        
        DrawInspectorGUI();

        serializedObject.ApplyModifiedProperties();

        if (GUI.changed)
        {
            mCustomerParticleMasked.GetType().InvokeMember("EditorInit", BindingFlags.Instance | BindingFlags.InvokeMethod | BindingFlags.NonPublic, null, mCustomerParticleMasked, new object[] { });;
            GUI.changed = false;
        }
    }

    protected override void DrawInspectorGUI()
    {
        base.DrawInspectorGUI();
        EditorGUILayout.PropertyField(m_SelfSoftMask, m_SelfSoftMaskContent);
        bUseCustomMaterial = EditorGUILayout.Toggle("Use Custom Material", bUseCustomMaterial);

        if (bUseCustomMaterial)
        {
            m_Texture.objectReferenceValue = null;
            EditorGUILayout.PropertyField(m_CustomMaterial);
        }
        else
        {
            m_CustomMaterial.objectReferenceValue = null;
            EditorGUILayout.PropertyField(m_Texture);
        }
    }

}
