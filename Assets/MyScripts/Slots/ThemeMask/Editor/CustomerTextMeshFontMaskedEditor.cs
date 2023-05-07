using UnityEngine;
using UnityEditor;
using System.Reflection;

/// <summary>
/// Editor class used to edit UI Graphics.
/// Extend this class to write your own graphic editor.
/// </summary>

[CustomEditor(typeof(CustomerTextMeshFontMasked), true)]
[CanEditMultipleObjects]
public class CustomerTextMeshFontMaskedEditor : CustomerRectMaskGroupChildrenEditor
{
    SerializedProperty orUseMaterialBlock;
    
    CustomerTextMeshFontMasked mTextMeshFontMasked;
    protected override void OnEnable()
    {
        base.OnEnable();
        orUseMaterialBlock = serializedObject.FindProperty("orUseMaterialBlock");
        
        mTextMeshFontMasked = target as CustomerTextMeshFontMasked;
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
    }

}
