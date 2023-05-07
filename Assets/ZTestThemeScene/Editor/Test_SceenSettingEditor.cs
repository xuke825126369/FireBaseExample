using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(Test_SceenSetting)), CanEditMultipleObjects]
public class Test_SceenSettingEditor : Editor
{
    public override void OnInspectorGUI()
    {
        Test_SceenSetting obj;
        obj = target as Test_SceenSetting;
        if (obj == null)
        {
            return;
        }

        base.DrawDefaultInspector();
        if (GUI.changed)
        {
            obj.Set();
        }

    }
}
