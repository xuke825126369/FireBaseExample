using UnityEngine;
using UnityEditor;
using System.Reflection;

/// <summary>
/// Editor class used to edit UI Graphics.
/// Extend this class to write your own graphic editor.
/// </summary>

[CustomEditor(typeof(CustomerTextMeshProMasked), true)]
[CanEditMultipleObjects]
public class CustomerTextMeshProMaskedEditor : CustomerRectMaskGroupChildrenEditor
{
    SerializedProperty m_Material;

    CustomerTextMeshProMasked mCustomerTextMeshProMasked = null;
    protected override void OnEnable()
    {
        base.OnEnable();
        mCustomerTextMeshProMasked = target as CustomerTextMeshProMasked;
        m_Material = serializedObject.FindProperty("m_Material");
    }
    
    public override void OnInspectorGUI () 
    {
        serializedObject.Update();
        DrawInspectorGUI();
        serializedObject.ApplyModifiedProperties();

        if (GUI.changed)
        {
            mCustomerTextMeshProMasked.GetType().InvokeMember("EditorInit", BindingFlags.Instance | BindingFlags.InvokeMethod | BindingFlags.NonPublic, null, mCustomerTextMeshProMasked, new object[] { });
            GUI.changed = false;
        }
    }

    protected override void DrawInspectorGUI()
    {
        base.DrawInspectorGUI();
        EditorGUILayout.PropertyField(m_Material);
    }

}
