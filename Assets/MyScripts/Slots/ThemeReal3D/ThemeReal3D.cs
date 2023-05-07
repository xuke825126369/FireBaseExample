using UnityEngine;
using UnityEngine.Events;
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using XLua;
using UnityEngine.SceneManagement;

namespace SlotsMania
{
	[System.Serializable]
    [ExecuteAlways]
    public class ThemeReal3D : MonoBehaviour
	{
		public GameObject goRuler = null;
		public enumLEVELTYPE m_enumLevelType = enumLEVELTYPE.enumLevelType_Null;
		public int nRowCount = 0;
		public int nReelCount = 0;
		public GameObject mSymbolPrefab = null;

		public enumReturnRateTYPE m_enumSimRateType = enumReturnRateTYPE.enumReturnType_Rate95;
		public int m_SimulationCount = 0;
		public int m_nSimRateType = 0;
		public int m_nSimulationMaxCoins = 200; //每把都压1
		public int m_nSimulationCoin0Count = 10; //每次玩到总金币小于1为止，一共玩10次，看看每次都是玩多少把到达的"小于1"

		public static ThemeReal3D instance;

		public Vector3 center;
		public float fRadius;
		public bool bRealTimeCurve = false;
        
        float m_fCentBoardX;
        float m_fCentBoardY;
        float m_fCentBoardZ;

        public LuaTable m_LuaTable = null;
		private Action<LuaTable> m_LuaSimulationFunc = null;
		public Action<LuaTable> m_LuaInitLevelParamFunc = null;

        List<GameObject> mObjList = null;

        string currentSceneName;

        private void Start()
        {
            currentSceneName = SceneManager.GetActiveScene().name;
        }

        private void Clear()
		{
            int nLoopCount = 0;
			while(transform.childCount > 0 && nLoopCount < 1000)
			{
				GameObject v = transform.GetChild(0).gameObject;
				DestroyImmediate(v);

				nLoopCount++;
			}
		}

		public void SetPosition()
		{
			Clear();
			
			GameObject obj = new GameObject("StickySymbolsDir");
			obj.transform.SetParent(transform);

			if (goRuler == null)
			{
				goRuler = GameObject.Find("LevelInfo/LevelBG/BiaoChi");
			}
			
			GameObject TopObj = goRuler.transform.Find("TOP").gameObject;
			GameObject BottomObj = goRuler.transform.Find("BOTTOM").gameObject;
			GameObject RightObj = goRuler.transform.Find("RIGHT").gameObject;
			GameObject LeftObj = goRuler.transform.Find("LEFT").gameObject;

			Vector3 posRight = RightObj.transform.position;
			Vector3 posLeft = LeftObj.transform.position;
			Vector3 posTop = TopObj.transform.position;
			Vector3 posBottom = BottomObj.transform.position;

			m_fCentBoardX = (posRight.x + posLeft.x) / 2.0f;
			m_fCentBoardY = (posTop.y + posBottom.y) / 2.0f;
			m_fCentBoardZ = (posTop.z + posBottom.z + posRight.z + posLeft.z) / 4.0f;

			float m_fAllReelsWidth = posRight.x - posLeft.x;
			float m_fReelHeight = posTop.y - posBottom.y;

			float m_fSymbolHeight = m_fReelHeight / nRowCount;
			float m_fSymbolWidth = m_fAllReelsWidth / nReelCount;

			float fMiddleReelIndex = (nReelCount - 1) / 2f;
			float fMiddleRowIndex = (nRowCount - 1) / 2f;

			for(int i = 0; i < nReelCount; i++)
			{
				GameObject go = new GameObject("Reel" + i.ToString());
				go.transform.SetParent(transform);
				go.transform.localScale = Vector3.one;

				float fPosX = (i - fMiddleReelIndex) * m_fSymbolWidth + m_fCentBoardX;
				go.transform.position = new Vector3(fPosX, m_fCentBoardY, m_fCentBoardZ);

				for (int j = 0; j < nRowCount; j++)
				{
					GameObject goSymbol = Instantiate<GameObject>(mSymbolPrefab);
					goSymbol.transform.SetParent(go.transform, false);
					goSymbol.transform.rotation = Quaternion.identity;
					goSymbol.transform.localScale = Vector3.one;
					
					float fPosY = (j - fMiddleRowIndex) * m_fSymbolHeight + m_fCentBoardY;
					Vector3 Pos = new Vector3(fPosX, fPosY, m_fCentBoardZ);
					goSymbol.transform.position = Pos;
					goSymbol.name = goSymbol.name + j;

                    CalculateSymbolTransform(goSymbol);
                }
			}
		}

	    void CalculateSymbolTransform(GameObject goSymbol)
		{
			GameObject goCuvePos = goSymbol.transform.FindDeepChild("CurvePos").gameObject;

			Vector3 Pos = goSymbol.transform.position;
			Pos -= new Vector3(0, m_fCentBoardY, 0);
			float angle = Pos.y / fRadius;
			angle = Mathf.Clamp(angle, -(float)Math.PI, (float)Math.PI);
			float PosX = Pos.x;
			float PosY = (float)(fRadius * Math.Sin(angle));
			float PosZ = Pos.z - (float)(fRadius * Math.Cos(angle));
			
			goCuvePos.transform.position = new Vector3(PosX, PosY, PosZ);

			float angle1 = angle / (2 * Mathf.PI) * 360;
            goCuvePos.transform.localRotation = Quaternion.AngleAxis(angle1, Vector3.right);
		}

        private void RealTimeUpdateCurve()
        {
            if (bRealTimeCurve == false)
            {
                return;
            }

            if (mObjList == null || mObjList.Count == 0)
            {
                mObjList = new List<GameObject>();
                foreach (Transform v in transform)
                {
                    if (v.transform.name.StartsWith("Reel", StringComparison.Ordinal))
                    {
                        Transform reelTran = v.transform;
                        foreach (Transform v1 in reelTran)
                        {
                            mObjList.Add(v1.gameObject);
                        }
                    }
                }
            }

            foreach (var v in mObjList)
            {
                CalculateSymbolTransform(v);
            }

        }
        
        private void Update()
        {
#if UNITY_EDITOR
            if (currentSceneName == "Scene")
            {
                return;
            }

            RealTimeUpdateCurve();
#endif
        }

        void Awake()
		{
			instance = this;
		}

		public void Simulation()
		{
			LuaTable m_LuaTable = null;
			var ThemeHelper = LuaMainEnv.Instance.GetLuaClientEnv().Global.GetInPath<LuaTable>("ThemeHelper");
			LuaFunction mLuaFunction = ThemeHelper.Get<LuaFunction>("isClassicLevel");
			object[] resultList = mLuaFunction.Call();
			bool isClassicLevel = (bool)resultList[0];
			if (isClassicLevel)
			{
				m_LuaTable = LuaMainEnv.Instance.GetLuaClientEnv().Global.GetInPath<LuaTable>("ClassicSlotsGameLua");
			}
			else
			{
				m_LuaTable = LuaMainEnv.Instance.GetLuaClientEnv().Global.GetInPath<LuaTable>("SlotsGameLua");
			}

			var m_LuaSimulationFunc = m_LuaTable.GetInPath<Action<LuaTable, int, int>>("onSimulationFunc");
			if (m_LuaSimulationFunc != null)
			{
				m_LuaSimulationFunc(m_LuaTable, (int)m_enumSimRateType, m_SimulationCount);
#if UNITY_EDITOR
				UnityEditor.AssetDatabase.Refresh();
#endif
				return;
			}
		}

	}
	
}
