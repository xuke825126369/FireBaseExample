using UnityEngine;
using UnityEditor;
using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.Serialization.Formatters.Binary;

using SlotsMania;

[CustomEditor(typeof(ThemeReal3DMaskModify))]
public class ThemeReal3DMaskModifyEditor : Editor
{
	public override void OnInspectorGUI()
	{
		base.DrawDefaultInspector();
		if(GUILayout.Button("生成", GUILayout.MaxWidth(200)))
		{
			ThemeReal3DMaskModify target1 = target as ThemeReal3DMaskModify;
			target1.ModifyMaterialInfo();
		}

	}
	
}