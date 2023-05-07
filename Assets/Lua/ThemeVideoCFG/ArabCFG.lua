
local ArabCFG = {
	BasicInfo = {
		nReelCount = 5,	
		nRowCount = 4,
	},

	SymbolList = {
		{nId = 1,	m_strPrefabName = "Symbol_10",		m_nSymbolType = 0,	m_frequency50 = {60}, 					m_frequency95 = {37}, 					m_frequency200 = {30}, 					m_fRewards = {0, 0, 1, 2, 5}},--J
		{nId = 2,	m_strPrefabName = "Symbol_J",		m_nSymbolType = 0,	m_frequency50 = {60}, 					m_frequency95 = {37}, 					m_frequency200 = {30}, 					m_fRewards = {0, 0, 1, 3, 6}},--Q
		{nId = 3,	m_strPrefabName = "Symbol_Q",		m_nSymbolType = 0,	m_frequency50 = {60}, 					m_frequency95 = {37}, 					m_frequency200 = {30}, 					m_fRewards = {0, 0, 2, 4, 8}},--K
		{nId = 4,	m_strPrefabName = "Symbol_K",		m_nSymbolType = 0,	m_frequency50 = {60}, 					m_frequency95 = {37}, 					m_frequency200 = {30}, 					m_fRewards = {0, 0, 2, 4, 8}},--A
		{nId = 5,	m_strPrefabName = "Symbol_A",		m_nSymbolType = 0,	m_frequency50 = {60}, 					m_frequency95 = {37}, 					m_frequency200 = {30}, 					m_fRewards = {0, 0, 3, 5, 10}},--HOU

		{nId = 6,	m_strPrefabName = "dadao",			m_nSymbolType = 0,	m_frequency50 = {20}, 					m_frequency95 = {20}, 					m_frequency200 = {20}, 					m_fRewards = {0, 0, 5, 8, 12}},--QINGWA
		{nId = 7,	m_strPrefabName = "feitan",			m_nSymbolType = 0,	m_frequency50 = {20}, 					m_frequency95 = {20}, 					m_frequency200 = {20}, 					m_fRewards = {0, 0, 5, 10, 15}},--NIAO
		{nId = 8,	m_strPrefabName = "meinv",			m_nSymbolType = 0,	m_frequency50 = {20}, 					m_frequency95 = {20}, 					m_frequency200 = {20}, 					m_fRewards = {0, 3, 8, 20, 50}},--MAO
		{nId = 9,	m_strPrefabName = "qiangtao",		m_nSymbolType = 0,	m_frequency50 = {20}, 					m_frequency95 = {20}, 					m_frequency200 = {20}, 					m_fRewards = {0, 2, 6, 12, 25}},--YV

		{nId = 10,	m_strPrefabName = "Scatter",		m_nSymbolType = 1,	m_frequency50 = {0, 20, 20, 20, 0}, 	m_frequency95 = {0, 20, 20, 20, 0}, 	m_frequency200 = {0, 20, 20, 20, 0}, 	m_fRewards = {0, 0, 0, 0, 0}}, --WILD
		{nId = 11,	m_strPrefabName = "Wild",			m_nSymbolType = 1,	m_frequency50 = {4}, 					m_frequency95 = {7}, 					m_frequency200 = {15},					m_fRewards = {0, 8, 15, 50, 150}},
	},	

}


return ArabCFG
