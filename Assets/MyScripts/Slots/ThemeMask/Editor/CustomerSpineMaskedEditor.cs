using UnityEngine;
using UnityEditor;
using System.Reflection;

/// <summary>
/// Editor class used to edit UI Graphics.
/// Extend this class to write your own graphic editor.
/// </summary>

[CustomEditor(typeof(CustomerSpineMasked), true)]
[CanEditMultipleObjects]
public class CustomerSpineMaskedEditor : CustomerRectMaskGroupChildrenEditor
{
    SerializedProperty m_Color;
    SerializedProperty m_SelfSoftMask;
    SerializedProperty m_CustomMaterialList;

    GUIContent m_SelfSoftMaskContent;

    CustomerSpineMasked mCustomerSpineMasked = null;
        
    protected override void OnEnable()
    {
        base.OnEnable();

        m_SelfSoftMaskContent = new GUIContent("Soft Mask");

        m_Color = serializedObject.FindProperty("m_Color");
        m_SelfSoftMask = serializedObject.FindProperty("m_SelfSoftMask");
        m_CustomMaterialList = serializedObject.FindProperty("m_CustomMaterialList");
        mCustomerSpineMasked = target as CustomerSpineMasked;
    }

    public override void OnInspectorGUI () 
    {
        serializedObject.Update();
        DrawInspectorGUI();
        serializedObject.ApplyModifiedProperties();

        if (GUI.changed)
        {
            mCustomerSpineMasked.GetType().InvokeMember("EditorInit", BindingFlags.Instance | BindingFlags.InvokeMethod | BindingFlags.NonPublic, null, mCustomerSpineMasked, new object[] {});
            GUI.changed = false;
        }
    }
    
    protected override void DrawInspectorGUI()
    {
        base.DrawInspectorGUI();
        EditorGUILayout.PropertyField(m_Color);
        EditorGUILayout.PropertyField(m_SelfSoftMask, m_SelfSoftMaskContent);
        EditorGUILayout.PropertyField(m_CustomMaterialList, true);
    }

}
