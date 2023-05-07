using UnityEngine;
using UnityEditor;
using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.Serialization.Formatters.Binary;

using SlotsMania;

[CustomEditor(typeof(ThemeReal3DModelChangeSkin))]
public class ModelChangeSkinEditor : Editor
{
	public override void OnInspectorGUI()
	{
		base.DrawDefaultInspector();
		if(GUILayout.Button("生成", GUILayout.MaxWidth(200)))
		{
			ThemeReal3DModelChangeSkin target1 = target as ThemeReal3DModelChangeSkin;
			target1.Execute();
		}

	}
	
}