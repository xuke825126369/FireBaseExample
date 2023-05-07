//using UnityEngine;
//using UnityEditor;
//using System;
//using System.IO;
//using System.Collections;
//using System.Collections.Generic;
//using System.Runtime.Serialization.Formatters.Binary;

//using SlotsMania;

//[CustomEditor(typeof(SlotsGame))]
//public class SlotGameEditor : Editor
//{
//	//key: levelID value: levelName
//	public Dictionary<int, string> LEVELID_LEVELNAMES = new Dictionary<int, string>()
//	{
//        {18, "Witch"},
//        {19, "SnowWhite"},
//		{20, "CollectLucky"},
//		{21, "FireRewind"},
//		{22, "WildBeast"},
//		{23, "CashRespins"},
//		{24, "Phoenix"},
//		{25, "FortunesOfGold"},
//		{26, "027_Shinydiamonds"},
//		{27, "MermaidMischief"},
//		{28, "GoldenEgypt"},
//        {29, "MonsterRiches"},
//		{30, "BuffaloGold"},
//		{31, "Smitten"},
//		{32, "GiantTreasure"},
//        {33, "MagicBall"},
//		{34, "ChiliLoco"},
//		{35, "SantaMania"},
//        {36, "RichOfVegas"},
//        {37, "ColossalDog"},
//        {38, "DiaDeAmor"},
//        {39, "Zues"},
//        {40, "VesuvianForture"},
//        {41, "Wolf"},
//        {42, "BierMania"},
//        {43, "FuXing"},
//        {44, "GoldenRush"},
//        {45, "VegasLink"},
//        {46, "OceanRomance"},
//        {47, "GreatZeus"},
//        {48, "FireDragon"},


//		// 101 到 125 被现有Classic关卡占用了

//	};
	
//	private static int tab=0;
//	private static SlotsGame instance;
//	private GUIContent cont;

//	GUIStyle styleHelpboxInner;

//	private float m_fReturnRateValue = 0.0f;

//	void Awake()
//	{
//		instance = (SlotsGame)target;
//		EditorUtility.SetDirty(instance);

//		int nVersion = instance.m_nVersion;

//		styleHelpboxInner = new GUIStyle("HelpBox");
//		styleHelpboxInner.padding = new RectOffset(4, 4, 4, 4);

//		bool bFrequency1000Flag = HasFrequency1000Level();
//		if( !bFrequency1000Flag )
//		{
//			for(int i=0; i<instance.Symbols.Count; ++i)
//			{
//				instance.Symbols[i].m_frequency1000 = new int[10]{0,0,0,0,0,0,0,0,0,0};
//			}
//		}
//	}

//	bool HasFrequency1000Level()
//	{
//		enumLEVELTYPE enumLevelType = instance.m_enumLevelType;
//		int nLevelType = (int)enumLevelType;
//		if( nLevelType>9900 )
//			return false;

//		return true;
//	}

//	public override void OnInspectorGUI()
//	{
//		instance = (SlotsGame)target;
//		GUI.changed = false;
//		float fTemp = 0;

//		EditorGUILayout.Space();

//		tab = GUILayout.Toolbar(tab, new string[] {"Symbol", "Payline", "Basic", "Math"});
//		if(tab == 0)
//		{
//			EditorGUILayout.Space();
			
//			for(int i=0; i<instance.Symbols.Count; ++i)
//			{
//				GUILayout.BeginVertical(styleHelpboxInner);

//				GUILayout.Label((instance.Symbols[i].prfab != null) ? instance.Symbols[i].prfab.name : "None");

//				instance.Symbols[i].SetPrefab((GameObject)EditorGUILayout.ObjectField("Prefab", instance.Symbols[i].prfab, typeof(GameObject), false));

//				instance.Symbols[i].type=(SymbolType)EditorGUILayout.EnumPopup("Type", (SymbolType)instance.Symbols[i].type);
//				instance.Symbols[i].m_nSymbolType = (int)(instance.Symbols[i].type);

//				GUILayout.BeginHorizontal();
//				GUILayout.Label("Tag: ");
//				instance.Symbols[i].m_strKindTag = EditorGUILayout.TextField(instance.Symbols[i].m_strKindTag);
//				GUILayout.EndHorizontal();

//				GUILayout.BeginHorizontal();
//				GUILayout.Label("Frequency95 ");
//				for(int j=0; j<instance.Reels.Count; ++j)
//				{
//					if((j != 0) && (!instance.Symbols[i].m_bFrequencyPerReel))
//					{
//						instance.Symbols[i].m_frequency95[j] = instance.Symbols[i].m_frequency95[0];
//					}
//					else
//					{
//						instance.Symbols[i].m_frequency95[j]=EditorGUILayout.IntField(instance.Symbols[i].m_frequency95[j], GUILayout.MaxWidth(30));
//					}
//				}
//				GUILayout.EndHorizontal();

//				GUILayout.BeginHorizontal();
//				GUILayout.Label("Frequency140 ");
//				for(int j=0; j<instance.Reels.Count; ++j)
//				{
//					if((j != 0) && (!instance.Symbols[i].m_bFrequencyPerReel))
//					{
//						instance.Symbols[i].m_frequency140[j] = instance.Symbols[i].m_frequency140[0];
//					}
//					else
//					{
//						instance.Symbols[i].m_frequency140[j]=EditorGUILayout.IntField(instance.Symbols[i].m_frequency140[j], GUILayout.MaxWidth(30));
//					}
//				}
//				GUILayout.EndHorizontal();

//				GUILayout.BeginHorizontal();
//				GUILayout.Label("Frequency50 ");
//				for(int j=0; j<instance.Reels.Count; ++j)
//				{
//					if((j != 0) && (!instance.Symbols[i].m_bFrequencyPerReel))
//					{
//						instance.Symbols[i].m_frequency50[j] = instance.Symbols[i].m_frequency50[0];
//					}
//					else
//					{
//						instance.Symbols[i].m_frequency50[j]=EditorGUILayout.IntField(instance.Symbols[i].m_frequency50[j], GUILayout.MaxWidth(30));
//					}
//				}
//				GUILayout.EndHorizontal();

//				GUILayout.BeginHorizontal();
//				GUILayout.Label("Frequency300 ");
//				for(int j=0; j<instance.Reels.Count; ++j)
//				{
//					if((j != 0) && (!instance.Symbols[i].m_bFrequencyPerReel))
//					{
//						instance.Symbols[i].m_frequency300[j] = instance.Symbols[i].m_frequency300[0];
//					}
//					else
//					{
//						instance.Symbols[i].m_frequency300[j]=EditorGUILayout.IntField(instance.Symbols[i].m_frequency300[j], GUILayout.MaxWidth(30));
//					}
//				}
//				GUILayout.EndHorizontal();

//				GUILayout.BeginHorizontal();
//				GUILayout.Label("Frequency70 ");
//				for(int j=0; j<instance.Reels.Count; ++j)
//				{
//					if((j != 0) && (!instance.Symbols[i].m_bFrequencyPerReel))
//					{
//						instance.Symbols[i].m_frequency20[j] = instance.Symbols[i].m_frequency20[0];
//					}
//					else
//					{
//						instance.Symbols[i].m_frequency20[j]=EditorGUILayout.IntField(instance.Symbols[i].m_frequency20[j], GUILayout.MaxWidth(30));

//					}
//				}
//				GUILayout.EndHorizontal();

//				GUILayout.BeginHorizontal();
//				GUILayout.Label("Frequency1000 ");
//				for(int j=0; j<instance.Reels.Count; ++j)
//				{
//					if((j != 0) && (!instance.Symbols[i].m_bFrequencyPerReel))
//					{
//						instance.Symbols[i].m_frequency1000[j] = instance.Symbols[i].m_frequency1000[0];
//					}
//					else
//					{
//						instance.Symbols[i].m_frequency1000[j] = 
//							EditorGUILayout.IntField(instance.Symbols[i].m_frequency1000[j], GUILayout.MaxWidth(30));
//					}
//				}
//				GUILayout.EndHorizontal();


//				instance.Symbols[i].m_bFrequencyPerReel=EditorGUILayout.ToggleLeft("Enable Frequency Per Reel", instance.Symbols[i].m_bFrequencyPerReel);
//				GUILayout.BeginHorizontal();

//				GUILayout.Label("Reward ");
//				int nMaxMatches = instance.Reels.Count;
				
//				for(int j=0; j<nMaxMatches; ++j)
//				{
//					instance.Symbols[i].m_fRewards[j]=EditorGUILayout.FloatField(instance.Symbols[i].m_fRewards[j], GUILayout.MaxWidth(39));
//				}
//				GUILayout.EndHorizontal();


//				GUILayout.EndVertical();
//			}
			
//			GUILayout.BeginHorizontal();
//			if(GUILayout.Button("+", GUILayout.MaxWidth(30)))
//				instance.SymbolAdd();
//			if(GUILayout.Button("-", GUILayout.MaxWidth(30)))
//				instance.SymbolRemove();
//			GUILayout.EndHorizontal();

//			EditorGUILayout.Space();
//		}
//		else if(tab == 1)
//		{
//			EditorGUILayout.Space();

//			List<string[]> listDisplayedOptions = new List<string[]>();
//			List<int[]> listOptionValues = new List<int[]>();

//			for(int num=0; num<instance.Reels.Count; ++num)
//			{
//				int nReelRow = instance.Reels[num].m_nReelRow;

//				string[] displayedOptions;
//				int[] optionValues;

//				if(nReelRow == 2)
//				{
//					displayedOptions = new string [] {"1","0"};
//					optionValues = new int[] {1,0};
//				}
//				else if(nReelRow == 3)
//				{
//					displayedOptions = new string [] {"2","1","0"};
//					optionValues = new int[] {2,1,0};
//				}
//				else if(nReelRow == 4)
//				{
//					displayedOptions = new string [] {"3","2","1","0"};
//					optionValues = new int[] {3,2,1,0};
//				} 
//				else if(nReelRow == 5)
//				{
//					displayedOptions = new string [] {"4","3","2","1","0"};
//					optionValues = new int[] {4,3,2,1,0};
//				} 
//				else if(nReelRow == 6)
//				{
//					displayedOptions = new string [] {"5","4","3","2","1","0"};
//					optionValues = new int[] {5,4,3,2,1,0};
//				} 
//				else if(nReelRow == 7)
//				{
//					displayedOptions = new string [] {"6","5","4","3","2","1","0"};
//					optionValues = new int[] {6,5,4,3,2,1,0};
//				} 
//				else
//				{
//					displayedOptions = new string [] {"x","x","x","x"};
//					optionValues = new int[] {0,0,0,0};
//				}

//				listDisplayedOptions.Add(displayedOptions);
//				listOptionValues.Add(optionValues);
//			}

//			for(int i=0; i<instance.Lines.Count; ++i)
//			{
//				GUILayout.BeginHorizontal();
				
//				GUILayout.Label("Line "+(i+1).ToString ("00"));

//				for(int j=0; j<instance.Reels.Count; ++j)
//				{
//					//instance.Lines[i].Slots[j]=(int)(Rows)EditorGUILayout.EnumPopup((Rows)instance.Lines[i].Slots[j],GUILayout.Width(30),GUILayout.MaxWidth(30));
//					instance.Lines[i].Slots[j]=EditorGUILayout.IntPopup(instance.Lines[i].Slots[j],listDisplayedOptions[j],listOptionValues[j],GUILayout.Width(30),GUILayout.MaxWidth(30));
//				}

//				instance.Lines[i].color=EditorGUILayout.ColorField(instance.Lines[i].color);

//				if(GUILayout.Button("+", GUILayout.MaxWidth(20)))
//					instance.LineInsert(i);
//				if(GUILayout.Button("-", GUILayout.MaxWidth(20)))
//					i-=instance.LineRemove(i);
				
//				GUILayout.EndHorizontal();
//			}

//			GUILayout.BeginHorizontal();
//			if(GUILayout.Button("+", GUILayout.MaxWidth(30)))
//				instance.LineAdd();
//			if(GUILayout.Button("-", GUILayout.MaxWidth(30)))
//				instance.LineRemove();
//			GUILayout.EndHorizontal();

//			EditorGUILayout.Space();
//		}
//		else if(tab == 2)
//		{
//			EditorGUILayout.Space();

//			EditorGUILayout.LabelField("Reel", EditorStyles.boldLabel);
//			GUILayout.BeginVertical(styleHelpboxInner);
				
//			GUILayout.BeginHorizontal();
//			EditorGUILayout.LabelField("Reel Count", EditorStyles.boldLabel, GUILayout.Width(120));
//			if(GUILayout.Button("-", GUILayout.MaxWidth(20)))
//			{
//				int nReelCount = instance.Reels.Count-1;
//				instance.SetReelCount(nReelCount);
//			}
//			GUILayout.Label(instance.Reels.Count.ToString (), GUILayout.MaxWidth(100));
//			if(GUILayout.Button("+", GUILayout.MaxWidth(20)))
//			{
//				int nReelCount = instance.Reels.Count+1;
//				instance.SetReelCount(nReelCount);
//			}
//			GUILayout.EndHorizontal();

//			GUILayout.BeginHorizontal();
//			EditorGUILayout.LabelField("Row Count", EditorStyles.boldLabel, GUILayout.Width(120));
//			if(GUILayout.Button("-", GUILayout.MaxWidth(20)))
//			{
//				int nRowCount = instance.RowCount-1;
//			//	nRowCount = nRowCount<3 ? 3:nRowCount;
//			//	nRowCount = nRowCount>4 ? 4:nRowCount;
//				instance.SetRowCount(nRowCount);
//			}
//			GUILayout.Label(instance.RowCount.ToString (), GUILayout.MaxWidth(100));
//			if(GUILayout.Button("+", GUILayout.MaxWidth(20)))
//			{
//				int nRowCount = instance.RowCount+1;
//			//	nRowCount = nRowCount<3 ? 3:nRowCount;
//			//	nRowCount = nRowCount>4 ? 4:nRowCount;
//				instance.SetRowCount(nRowCount);
//			}
//			GUILayout.EndHorizontal();
//			GUILayout.EndVertical();
			
//			EditorGUILayout.LabelField("Spin", EditorStyles.boldLabel);
//			GUILayout.BeginVertical(styleHelpboxInner);

//			fTemp = EditorGUILayout.IntSlider("BoundSpeed", (int)(instance.BoundSpeed), 1, 50);
//			instance.BoundSpeed = fTemp; // /100.0f;

//			fTemp = EditorGUILayout.IntSlider("SpeedMax", (int)(instance.SpeedMax), 100, 5000);
//			instance.SpeedMax = fTemp; // /100.0f;

//			fTemp = EditorGUILayout.IntSlider("Rotate Distance", (int)(instance.RotateDistance), 100, 5000);
//			instance.RotateDistance = fTemp; // /100.0f;

//			GUILayout.EndVertical();

//			EditorGUILayout.LabelField("ReturnRateCoef", EditorStyles.boldLabel);
//			GUILayout.BeginVertical(styleHelpboxInner);

//			instance.m_bReturnRateEnable = EditorGUILayout.ToggleLeft("Enable Return Rate Param", instance.m_bReturnRateEnable);

//			GUILayout.BeginHorizontal();
//			GUILayout.Label("BaseRandom: ");
//			instance.m_nReturnRateBaseRandom = EditorGUILayout.IntField(instance.m_nReturnRateBaseRandom);
//			GUILayout.EndHorizontal();

//			GUILayout.BeginHorizontal();

//			GUILayout.Label("ReturnRate300: " + instance.m_fReturnRate300Value.ToString("0.00"));
//			instance.m_fReturnRate300 = EditorGUILayout.FloatField(instance.m_fReturnRate300);
//			GUILayout.EndHorizontal();

//			GUILayout.BeginHorizontal();
//			GUILayout.Label("ReturnRate140: " + instance.m_fReturnRate140Value.ToString("0.00"));
//			instance.m_fReturnRate140 = EditorGUILayout.FloatField(instance.m_fReturnRate140);
//			GUILayout.EndHorizontal();

//			GUILayout.BeginHorizontal();
//			GUILayout.Label("ReturnRate50: " + instance.m_fReturnRate50Value.ToString("0.00"));
//			instance.m_fReturnRate50 = EditorGUILayout.FloatField(instance.m_fReturnRate50);
//			GUILayout.EndHorizontal();

//			GUILayout.BeginHorizontal();
//			GUILayout.Label("ReturnRate70: " + instance.m_fReturnRate70Value.ToString("0.00"));
//			instance.m_fReturnRate70 = EditorGUILayout.FloatField(instance.m_fReturnRate70);
//			GUILayout.EndHorizontal();

//			GUILayout.BeginHorizontal();
//			if(GUILayout.Button("CheckCoef", GUILayout.MaxWidth(100)))
//			{
//				CheckReturnCoefCoef();
//			}
//			GUILayout.EndHorizontal();

//			CheckReturnCoefCoef();

//			GUILayout.BeginHorizontal();
//			GUILayout.Label("ReturnRateValue: ");
//			m_fReturnRateValue = EditorGUILayout.FloatField(m_fReturnRateValue);
//			GUILayout.EndHorizontal();

//			GUILayout.EndVertical();

//			GUILayout.BeginHorizontal();
//			if(GUILayout.Button("标尺 对齐", GUILayout.MaxWidth(100)))
//			{
//				instance.initPositionParam ();
//			}
//			GUILayout.EndHorizontal();

//		}
//		else if(tab == 3)
//		{
//			//EditorGUILayout.Space();
			
//			//EditorGUILayout.LabelField("Simulation", EditorStyles.boldLabel);
			
//			//GUILayout.BeginVertical(styleHelpboxInner);
//			//instance.m_enumSimRateType = (enumReturnRateTYPE)EditorGUILayout.EnumPopup("Type", instance.m_enumSimRateType);
//			//instance.m_nSimRateType = (int)(instance.m_enumSimRateType);
//			//GUILayout.EndVertical();

//			//GUILayout.BeginVertical(styleHelpboxInner);

//			//int nMaxNum = 20000;
//			//fTemp = EditorGUILayout.IntSlider("Count", (int)instance.m_SimulationCount, 1000, nMaxNum);
//			//instance.m_bTestSimuData = EditorGUILayout.ToggleLeft("bTestSimuData", instance.m_bTestSimuData);

//			//instance.m_nSimulationMaxCoins = EditorGUILayout.IntSlider("nMaxCoins", instance.m_nSimulationMaxCoins, 50, 1000);
//			//instance.m_nSimulationCoin0Count = EditorGUILayout.IntSlider("nCoin0Count", instance.m_nSimulationCoin0Count, 1, 100);

//			//if((int)fTemp != instance.m_SimulationCount)
//			//{
//			//	instance.m_SimulationCount = (int)fTemp;
//			//}

//			//if(GUILayout.Button("Start", GUILayout.MaxWidth(120)))
//			//{
//			//	instance.Simulation();
//			//	EditorUtility.SetDirty(instance);
//			//}

//			//GUILayout.EndVertical();

//			//bool bCshapLevelFlag = (int)(instance.m_enumLevelType) <= 18;
//			//if(!bCshapLevelFlag || instance.m_bTestSimuData)
//			//	return;
//		}
//		else if(tab == 4)
//		{
			
//		}
//		else
//		{
			
//		}
		
//		EditorGUILayout.Space();

//		if(GUI.changed)
//		{
//			EditorUtility.SetDirty(instance);
//		}

//		string strPath = "NewGameNode/LevelInfo";
//		GameObject go = GameObject.Find(strPath);

//		CurveItem[] curveItems = go.GetComponentsInChildren<CurveItem>();
//		if (curveItems != null) {
//			foreach (var item in curveItems) {
//				item.Build ();
//			}
//		}
//	}

//	void CheckReturnCoefCoef()
//	{
//		if(instance.m_nReturnRateBaseRandom < 5)
//			instance.m_nReturnRateBaseRandom = 5;

//		float fCoef300 = instance.m_fReturnRate300;
//		float fCoef140 = instance.m_fReturnRate140;
//		float fCoef50 = instance.m_fReturnRate50;
//		float fCoef70 = instance.m_fReturnRate70;

//		float fReturn300Value = instance.m_fReturnRate300Value;
//		float fReturn140Value = instance.m_fReturnRate140Value;
//		float fReturn50Value = instance.m_fReturnRate50Value;
//		float fReturn20Value = instance.m_fReturnRate70Value;

//		m_fReturnRateValue = (fReturn300Value * fCoef300 + fReturn140Value * fCoef140 + 
//								fReturn50Value * fCoef50 + fReturn20Value * fCoef70)/
//								(fCoef300 + fCoef140 + fCoef50 + fCoef70);
//	}

//	private static string getJsonByObject(System.Object obj)
//	{
//		return JsonUtility.ToJson(obj);
//	}
	 
//	private static SlotsGame getObjectByJson(string jsonString)
//	{
//		return JsonUtility.FromJson<SlotsGame> (jsonString);
//	}
	
//}