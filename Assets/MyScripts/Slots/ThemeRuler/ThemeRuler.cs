using UnityEngine;
using System.Collections.Generic;
using System;
using XLua;

namespace SlotsMania
{
	[System.Serializable]
    [ExecuteAlways]
    public class ThemeRuler : MonoBehaviour
	{
		public enumLEVELTYPE m_enumLevelType = enumLEVELTYPE.enumLevelType_Null;
		public enumReturnRateTYPE m_enumSimRateType = enumReturnRateTYPE.enumReturnType_Rate95;
		public int m_SimulationCount = 0;

		public GameObject goRuler = null;
		public GameObject goLevelData = null;
		public int nRowCount = 0;
		public int nReelCount = 0;
		public GameObject mSymbolPrefab = null;
        
        float m_fCentBoardX;
        float m_fCentBoardY;
        float m_fCentBoardZ;

        List<GameObject> mObjList = null;

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

		void OnDestroy()
		{
			
		}

		private void Clear()
		{
            int nLoopCount = 0;
			while(goLevelData.transform.childCount > 0 && nLoopCount < 1000)
			{
				nLoopCount++;
				
				for(int i = 0; i < goLevelData.transform.childCount; i++)
                {
					GameObject v = goLevelData.transform.GetChild(i).gameObject;
					if (v.name.StartsWith("Reel"))
					{
						DestroyImmediate(v);
						break;
					}

					if (i == goLevelData.transform.childCount - 1)
                    {
						return;
                    }
				}
			}
		}

		public void SetPosition()
		{
			if(goLevelData == null)
			{
				goLevelData = transform.gameObject;
			}

			Clear();

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

			goLevelData.transform.position = new Vector3(m_fCentBoardX, m_fCentBoardY, m_fCentBoardZ);

			float m_fAllReelsWidth = posRight.x - posLeft.x;
			float m_fReelHeight = posTop.y - posBottom.y;

			float m_fSymbolHeight = m_fReelHeight / nRowCount;
			float m_fSymbolWidth = m_fAllReelsWidth / nReelCount;

			float fMiddleReelIndex = (nReelCount - 1) / 2f;
			float fMiddleRowIndex = (nRowCount - 1) / 2f;

			for (int i = 0; i < nReelCount; i++)
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
				}
			}
		}
	}
}
