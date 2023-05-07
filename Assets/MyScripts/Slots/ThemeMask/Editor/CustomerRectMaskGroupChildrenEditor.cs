using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(CustomerRectMaskGroupChildren), false)]
[CanEditMultipleObjects]
public class CustomerRectMaskGroupChildrenEditor : Editor
{
    protected SerializedProperty m_RectMaskGroup;
    protected SerializedProperty m_ValidParentMaskGroup;

    protected virtual void OnEnable()
    {
        m_RectMaskGroup = serializedObject.FindProperty("m_RectMaskGroup");
        m_ValidParentMaskGroup = serializedObject.FindProperty("m_ValidParentMaskGroup");
    }
    
    protected virtual void DrawInspectorGUI()
    {
        m_ValidParentMaskGroup.boolValue = EditorGUILayout.Toggle("Valid Parent RectMask", m_ValidParentMaskGroup.boolValue);

        if (!m_ValidParentMaskGroup.boolValue)
        {
           EditorGUILayout.PropertyField(m_RectMaskGroup);    
        }
    }
    
}
