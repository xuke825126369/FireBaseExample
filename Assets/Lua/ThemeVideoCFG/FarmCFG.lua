
local FarmCFG = {
	BasicInfo = {
		nReelCount = 5,	
		nRowCount = 3,
	},

	SymbolList = {
		{nId = 1,	m_strPrefabName = "apple",		m_nSymbolType = 0,	m_frequency50 = {60}, 		m_frequency95 = {60}, 		m_frequency200 = {60}, 			m_fRewards = {0, 0, 10, 30, 80}},--J
		{nId = 2,	m_strPrefabName = "yangcong",	m_nSymbolType = 0,	m_frequency50 = {60}, 		m_frequency95 = {60}, 		m_frequency200 = {60}, 			m_fRewards = {0, 0, 10, 30, 80}},--YV
		{nId = 3,	m_strPrefabName = "huluobo",	m_nSymbolType = 0,	m_frequency50 = {60}, 		m_frequency95 = {60}, 		m_frequency200 = {60}, 			m_fRewards = {0, 0, 10, 30, 80}},--HOU

		{nId = 4,	m_strPrefabName = "baomi",		m_nSymbolType = 0,	m_frequency50 = {60}, 		m_frequency95 = {60}, 		m_frequency200 = {60}, 			m_fRewards = {0, 0, 20, 50, 100}},--Q
		{nId = 5,	m_strPrefabName = "nangua",		m_nSymbolType = 0,	m_frequency50 = {60}, 		m_frequency95 = {60}, 		m_frequency200 = {60}, 			m_fRewards = {0, 0, 20, 50, 100}},--QINGWA
		
		{nId = 6,	m_strPrefabName = "sheep",		m_nSymbolType = 0,	m_frequency50 = {30}, 		m_frequency95 = {30}, 		m_frequency200 = {50}, 			m_fRewards = {0, 2, 25, 100, 200}},--MAO
		{nId = 7,	m_strPrefabName = "dog",		m_nSymbolType = 0,	m_frequency50 = {30}, 		m_frequency95 = {30}, 		m_frequency200 = {50}, 			m_fRewards = {0, 3, 30, 150, 300}},--A
		{nId = 8,	m_strPrefabName = "pig",		m_nSymbolType = 0,	m_frequency50 = {30}, 		m_frequency95 = {30}, 		m_frequency200 = {50}, 			m_fRewards = {0, 4, 40, 200, 500}},--NIAO
		{nId = 9,	m_strPrefabName = "cow",		m_nSymbolType = 0,	m_frequency50 = {30}, 		m_frequency95 = {30}, 		m_frequency200 = {50}, 			m_fRewards = {0, 5, 50, 250, 1000}},--K

		{nId = 10,	m_strPrefabName = "scatter",	m_nSymbolType = 1,	m_frequency50 = {55}, 		m_frequency95 = {5}, 		m_frequency200 = {5}, 			m_fRewards = {0, 0, 0, 0, 0}}, --WILD
		{nId = 11,	m_strPrefabName = "wild",		m_nSymbolType = 1,	m_frequency50 = {5}, 		m_frequency95 = {11}, 		m_frequency200 = {12},			m_fRewards = {0, 0, 20, 50, 100}},
		{nId = 12,	m_strPrefabName = "WILDX3",		m_nSymbolType = 1,	m_frequency50 = {0, 0, 4}, 	m_frequency95 = {0, 0, 4}, 	m_frequency200 = {0, 0, 15},	m_fRewards = {0, 0, 0, 0, 0}},
	},	

}


return FarmCFG
