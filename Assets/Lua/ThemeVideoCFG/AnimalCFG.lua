
local AnimalCFG = {
	BasicInfo = {
		nReelCount = 5,	
		nRowCount = 4,
	},
	
	SymbolList = {
		{nId = 1,	m_strPrefabName = "Symbol_10",		m_nSymbolType = 0,	m_frequency50 = {20}, 		m_frequency95 = {20}, 		m_frequency200 = {10}, 		m_fRewards = {0, 0, 5, 20, 60}},--J
		{nId = 2,	m_strPrefabName = "Symbol_J",		m_nSymbolType = 0,	m_frequency50 = {20}, 		m_frequency95 = {20}, 		m_frequency200 = {10}, 		m_fRewards = {0, 0, 5, 20, 60}},--Q
		{nId = 3,	m_strPrefabName = "Symbol_Q",		m_nSymbolType = 0,	m_frequency50 = {20}, 		m_frequency95 = {20}, 		m_frequency200 = {10}, 		m_fRewards = {0, 0, 5, 20, 60}},--K
		{nId = 4,	m_strPrefabName = "Symbol_K",		m_nSymbolType = 0,	m_frequency50 = {20}, 		m_frequency95 = {20}, 		m_frequency200 = {10}, 		m_fRewards = {0, 0, 10, 25, 75}},--A
		{nId = 5,	m_strPrefabName = "Symbol_A",		m_nSymbolType = 0,	m_frequency50 = {20}, 		m_frequency95 = {20}, 		m_frequency200 = {10}, 		m_fRewards = {0, 0, 10, 25, 75}},--HOU

		{nId = 6,	m_strPrefabName = "whitetiger",		m_nSymbolType = 0,	m_frequency50 = {27}, 		m_frequency95 = {26}, 		m_frequency200 = {20}, 		m_fRewards = {0, 0, 20, 75, 150}},--QINGWA
		{nId = 7,	m_strPrefabName = "orangutan",		m_nSymbolType = 0,	m_frequency50 = {20}, 		m_frequency95 = {20}, 		m_frequency200 = {20}, 		m_fRewards = {0, 0, 15, 50, 125}},--NIAO
		{nId = 8,	m_strPrefabName = "bear",			m_nSymbolType = 0,	m_frequency50 = {20}, 		m_frequency95 = {20}, 		m_frequency200 = {20}, 		m_fRewards = {0, 0, 15, 50, 125}},--MAO
		{nId = 9,	m_strPrefabName = "hippo",			m_nSymbolType = 0,	m_frequency50 = {20}, 		m_frequency95 = {20}, 		m_frequency200 = {20}, 		m_fRewards = {0, 0, 15, 50, 125}},--YV
		{nId = 10,	m_strPrefabName = "lion",			m_nSymbolType = 0,	m_frequency50 = {27}, 		m_frequency95 = {27}, 		m_frequency200 = {20}, 		m_fRewards = {0, 0, 20, 75, 150}},--NVJUESE

		{nId = 11,	m_strPrefabName = "SCATTER",		m_nSymbolType = 1,	m_frequency50 = {20}, 		m_frequency95 = {20}, 		m_frequency200 = {20}, 		m_fRewards = {0, 0, 0, 0, 0}}, --WILD
		{nId = 12,	m_strPrefabName = "WILD",			m_nSymbolType = 1,	m_frequency50 = {0, 12}, 	m_frequency95 = {0, 20}, 	m_frequency200 = {0, 20},	m_fRewards = {0, 0, 0, 0, 0}},
	},	

}


return AnimalCFG
