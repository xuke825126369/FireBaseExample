using UnityEngine;
using UnityEditor;
using System;
using System.IO;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.Serialization.Formatters.Binary;

using SlotsMania;

[CustomEditor(typeof(ThemeReal3D))]
public class ThemeReal3DEditor : Editor
{
	private static ThemeReal3D instance;
	GUIStyle styleHelpboxInner;
	void Awake()
	{
		instance = (ThemeReal3D)target;
		EditorUtility.SetDirty(instance);

		styleHelpboxInner = new GUIStyle("HelpBox");
		styleHelpboxInner.padding = new RectOffset(4, 4, 4, 4);
	}

	public override void OnInspectorGUI()
	{
		instance = (ThemeReal3D)target;
		GUI.changed = false;

		EditorGUILayout.LabelField("Basic", EditorStyles.boldLabel);
		
		GUILayout.BeginVertical(styleHelpboxInner);
		instance.m_enumLevelType = (enumLEVELTYPE)EditorGUILayout.EnumPopup("Type", instance.m_enumLevelType);
		instance.goRuler = (GameObject)EditorGUILayout.ObjectField("BiaoChi", instance.goRuler, typeof(GameObject), true);
		instance.mSymbolPrefab = (GameObject)EditorGUILayout.ObjectField("Symbol Prefab", instance.mSymbolPrefab, typeof(GameObject), false);
		GUILayout.BeginHorizontal();
		EditorGUILayout.LabelField("ReelCount", EditorStyles.boldLabel, GUILayout.Width(80));
		if(GUILayout.Button("-", GUILayout.MaxWidth(20)))
		{
			instance.nReelCount--;
			instance.SetPosition();
		}
		GUILayout.Label(instance.nReelCount.ToString(), GUILayout.MaxWidth(30));
		if(GUILayout.Button("+", GUILayout.MaxWidth(20)))
		{
			instance.nReelCount++;
			instance.SetPosition();
		}
		GUILayout.EndHorizontal();

		GUILayout.BeginHorizontal();
		EditorGUILayout.LabelField("RowCount", EditorStyles.boldLabel, GUILayout.Width(80));
		if(GUILayout.Button("-", GUILayout.MaxWidth(20)))
		{
			instance.nRowCount--;
			instance.SetPosition();
		}
		GUILayout.Label(instance.nRowCount.ToString (), GUILayout.MaxWidth(30));
		if(GUILayout.Button("+", GUILayout.MaxWidth(20)))
		{
			instance.nRowCount++;
			instance.SetPosition();
		}
		GUILayout.EndHorizontal();
		// 标尺对齐
		if(GUILayout.Button("标尺 对齐", GUILayout.MaxWidth(100)))
		{
			instance.SetPosition();
		}
		GUILayout.EndVertical();
		EditorGUILayout.Space();

		EditorGUILayout.LabelField("Cylinder", EditorStyles.boldLabel);
		GUILayout.BeginVertical(styleHelpboxInner);

        GUILayout.BeginHorizontal();
        EditorGUILayout.LabelField("实时弯曲", EditorStyles.boldLabel, GUILayout.Width(80));
        instance.bRealTimeCurve = EditorGUILayout.Toggle(instance.bRealTimeCurve);
        GUILayout.EndHorizontal();
        GUILayout.BeginHorizontal();
		EditorGUILayout.LabelField("半径", EditorStyles.boldLabel, GUILayout.Width(80));
		instance.fRadius = EditorGUILayout.FloatField(instance.fRadius, GUILayout.Width(80));
		GUILayout.EndHorizontal();
		if(GUILayout.Button("弯曲", GUILayout.MaxWidth(100)))
		{
			instance.SetPosition();
		}
		GUILayout.EndVertical();
		EditorGUILayout.Space();
		
		// 仿真相关
		EditorGUILayout.LabelField("Simulation", EditorStyles.boldLabel);
		GUILayout.BeginVertical(styleHelpboxInner);
		instance.m_enumSimRateType = (enumReturnRateTYPE)EditorGUILayout.EnumPopup("Type", instance.m_enumSimRateType);
		instance.m_nSimRateType = (int)(instance.m_enumSimRateType);
		
		int nMinNum = 0;
		int nMaxNum = 100000;
		instance.m_SimulationCount = EditorGUILayout.IntSlider("Count", (int)instance.m_SimulationCount, nMinNum, nMaxNum);
		instance.m_nSimulationMaxCoins = EditorGUILayout.IntSlider("nMaxCoins", instance.m_nSimulationMaxCoins, 50, 1000);
		instance.m_nSimulationCoin0Count = EditorGUILayout.IntSlider("nCoin0Count", instance.m_nSimulationCoin0Count, 1, 100);
		
		if(GUILayout.Button("Start", GUILayout.MaxWidth(120)))
		{
			instance.Simulation();
			EditorUtility.SetDirty(instance);
		}

		GUILayout.EndVertical();
	}
	
}