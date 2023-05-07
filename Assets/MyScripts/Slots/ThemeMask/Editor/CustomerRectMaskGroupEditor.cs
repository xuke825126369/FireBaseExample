using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.Reflection;

[CustomEditor(typeof(CustomerRectMaskGroup), true)]
[CanEditMultipleObjects]
public class CustomerRectMaskGroupEditor : Editor
{
    private SerializedProperty m_SpriteMask;
    private GUIContent m_CorrectButtonContent;
	private CustomerRectMaskGroup mCustomerRectMaskGroup;
    
    private void OnEnable()
    {
        m_SpriteMask = serializedObject.FindProperty("m_SpriteMask");
		mCustomerRectMaskGroup = target as CustomerRectMaskGroup;
    }

    public override void OnInspectorGUI()
    {
        serializedObject.Update();

        DrawInspectorGUI();
        
        serializedObject.ApplyModifiedProperties();
    }

    private void DrawInspectorGUI()
    {
        EditorGUILayout.PropertyField(m_SpriteMask);
        
        var mChildrenListFieldInfo = mCustomerRectMaskGroup.GetType().GetField("mChildrenList", BindingFlags.Instance | BindingFlags.GetField | BindingFlags.NonPublic);
        if (mChildrenListFieldInfo != null)
        {
            var mChildrenList = mChildrenListFieldInfo.GetValue(mCustomerRectMaskGroup) as List<CustomerRectMaskGroupChildren>;
            EditorGUILayout.LabelField("mChildrenList: " + mChildrenList.Count);
            for (int i = 0; i < mChildrenList.Count; ++i)
            {
                if (mChildrenList[i])
                {
                    EditorGUILayout.ObjectField("", mChildrenList[i].gameObject, typeof(GameObject), false);
                }
            }
        }
        else
        {
            Debug.LogError("GetField Error ");
        }
	}
    
}
