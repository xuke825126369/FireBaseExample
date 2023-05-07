
local TroyCFG = {
	BasicInfo = {
		nReelCount = 5,	
		nRowCount = 3,
	},	
	
	SymbolList = {
		{nId = 1,	m_strPrefabName = "10",				m_nSymbolType = 0,		m_frequency50 = {90}, 		m_frequency95 = {60}, 		m_frequency200 = {60}, 		m_fRewards = {0, 0, 5, 10, 25}},
		{nId = 2,	m_strPrefabName = "J",				m_nSymbolType = 0,		m_frequency50 = {80}, 		m_frequency95 = {60}, 		m_frequency200 = {60}, 		m_fRewards = {0, 0, 5, 10, 25}},
		{nId = 3,	m_strPrefabName = "Q",				m_nSymbolType = 0,		m_frequency50 = {70}, 		m_frequency95 = {60}, 		m_frequency200 = {60}, 		m_fRewards = {0, 0, 5, 10, 25}},
		{nId = 4,	m_strPrefabName = "K",				m_nSymbolType = 0,		m_frequency50 = {60}, 		m_frequency95 = {60}, 		m_frequency200 = {60}, 		m_fRewards = {0, 0, 5, 10, 25}},

		{nId = 5,	m_strPrefabName = "chuan",			m_nSymbolType = 0,		m_frequency50 = {40}, 		m_frequency95 = {60}, 		m_frequency200 = {60}, 		m_fRewards = {0, 0, 7, 15, 50}},
		{nId = 6,	m_strPrefabName = "dun",			m_nSymbolType = 0,		m_frequency50 = {30}, 		m_frequency95 = {60}, 		m_frequency200 = {60}, 		m_fRewards = {0, 0, 7, 15, 50}},
		{nId = 7,	m_strPrefabName = "toukui",			m_nSymbolType = 0,		m_frequency50 = {20}, 		m_frequency95 = {60}, 		m_frequency200 = {60}, 		m_fRewards = {0, 0, 7, 15, 50}},
		{nId = 8,	m_strPrefabName = "zhanshen",		m_nSymbolType = 0,		m_frequency50 = {10}, 		m_frequency95 = {60}, 		m_frequency200 = {60}, 		m_fRewards = {0, 0, 10, 20, 100}},
		{nId = 9,	m_strPrefabName = "wangzi",			m_nSymbolType = 0,		m_frequency50 = {5}, 		m_frequency95 = {60}, 		m_frequency200 = {60}, 		m_fRewards = {0, 0, 25, 50, 150}},
		
		{nId = 10,	m_strPrefabName = "scatter",		m_nSymbolType = 1,		m_frequency50 = {10}, 		m_frequency95 = {10}, 		m_frequency200 = {10}, 		m_fRewards = {0, 0, 0, 0, 0}},
		{nId = 11,	m_strPrefabName = "normalWild",		m_nSymbolType = 1,		m_frequency50 = {0, 27}, 	m_frequency95 = {0, 52}, 	m_frequency200 = {0, 67}, 	m_fRewards = {0, 5, 40, 100, 500}},
		{nId = 12,	m_strPrefabName = "NormalWild_1",	m_nSymbolType = 1,		m_frequency50 = {0}, 		m_frequency95 = {0}, 		m_frequency200 = {0}, 		m_fRewards = {0, 0, 0, 0, 0}},
		{nId = 13,	m_strPrefabName = "nvshenWild",		m_nSymbolType = 1,		m_frequency50 = {27, 0}, 	m_frequency95 = {52, 0}, 	m_frequency200 = {67, 0}, 	m_fRewards = {0, 5, 40, 100, 500}},
		{nId = 14,	m_strPrefabName = "nvshenWild_1",	m_nSymbolType = 1,		m_frequency50 = {0}, 		m_frequency95 = {0}, 		m_frequency200 = {0}, 		m_fRewards = {0, 0, 0, 0, 0}},
		{nId = 15,	m_strPrefabName = "NullSymbol",		m_nSymbolType = 1,		m_frequency50 = {0}, 		m_frequency95 = {0}, 		m_frequency200 = {0}, 		m_fRewards = {0, 0, 0, 0, 0}},

	}

}	


return TroyCFG
