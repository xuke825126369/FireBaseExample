using UnityEngine;
using UnityEditor;

using SlotsMania;

[CustomEditor(typeof(ThemeRuler))]
public class ThemeRulerEditor : Editor
{
	private static ThemeRuler instance;
	GUIStyle styleHelpboxInner;
	static int tab = 0;
	void Awake()
	{
		instance = (ThemeRuler)target;
		EditorUtility.SetDirty(instance);

		styleHelpboxInner = new GUIStyle("HelpBox");
		styleHelpboxInner.padding = new RectOffset(4, 4, 4, 4);
	}

	public override void OnInspectorGUI()
	{
		instance = (ThemeRuler)target;
		GUI.changed = false;

		tab = GUILayout.Toolbar(tab, new string[] { "Basic", "Math"});
		if (tab == 0)
		{
			EditorGUILayout.LabelField("Basic", EditorStyles.boldLabel);

			GUILayout.BeginVertical(styleHelpboxInner);
			instance.m_enumLevelType = (enumLEVELTYPE)EditorGUILayout.EnumPopup("LevelType", instance.m_enumLevelType);
			instance.goLevelData = (GameObject)EditorGUILayout.ObjectField("LevelData", instance.goLevelData, typeof(GameObject), true);
			instance.goRuler = (GameObject)EditorGUILayout.ObjectField("BiaoChi", instance.goRuler, typeof(GameObject), true);
			instance.mSymbolPrefab = (GameObject)EditorGUILayout.ObjectField("Symbol Prefab", instance.mSymbolPrefab, typeof(GameObject), false);
			GUILayout.BeginHorizontal();
			EditorGUILayout.LabelField("ReelCount", EditorStyles.boldLabel, GUILayout.Width(80));
			if (GUILayout.Button("-", GUILayout.MaxWidth(20)))
			{
				instance.nReelCount--;
				instance.SetPosition();
			}
			GUILayout.Label(instance.nReelCount.ToString(), GUILayout.MaxWidth(30));
			if (GUILayout.Button("+", GUILayout.MaxWidth(20)))
			{
				instance.nReelCount++;
				instance.SetPosition();
			}
			GUILayout.EndHorizontal();

			GUILayout.BeginHorizontal();
			EditorGUILayout.LabelField("RowCount", EditorStyles.boldLabel, GUILayout.Width(80));
			if (GUILayout.Button("-", GUILayout.MaxWidth(20)))
			{
				instance.nRowCount--;
				instance.SetPosition();
			}
			GUILayout.Label(instance.nRowCount.ToString(), GUILayout.MaxWidth(30));
			if (GUILayout.Button("+", GUILayout.MaxWidth(20)))
			{
				instance.nRowCount++;
				instance.SetPosition();
			}
			GUILayout.EndHorizontal();
			// 标尺对齐
			if (GUILayout.Button("标尺 对齐", GUILayout.MaxWidth(100)))
			{
				instance.SetPosition();
			}
			GUILayout.EndVertical();
			EditorGUILayout.Space();
		}
		else
		{
			EditorGUILayout.Space();

			EditorGUILayout.LabelField("Simulation", EditorStyles.boldLabel);

			GUILayout.BeginVertical(styleHelpboxInner);
			instance.m_enumSimRateType = (enumReturnRateTYPE)EditorGUILayout.EnumPopup("Type", instance.m_enumSimRateType);
			GUILayout.EndVertical();

			GUILayout.BeginVertical(styleHelpboxInner);

			int nMaxNum = 60000;
			instance.m_SimulationCount = EditorGUILayout.IntSlider("Count", (int)instance.m_SimulationCount, 1000, nMaxNum);

			if (GUILayout.Button("Start", GUILayout.MaxWidth(120)))
			{
				instance.Simulation();
				EditorUtility.SetDirty(instance);
			}

			GUILayout.EndVertical();
		}
	}
	
}