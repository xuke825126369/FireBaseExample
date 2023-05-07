
local IrishCFG = {
	BasicInfo = {
		nReelCount = 3,	
		nRowCount = 3,
	},

	SymbolList = {
		{nId = 1,	m_strPrefabName = "Symbol_1Bar",		m_nSymbolType = 0,		m_frequency50 = {60}, 		m_frequency95 = {90}, 		m_frequency200 = {60}, 		m_fRewards = {0, 0, 5}},
		{nId = 2,	m_strPrefabName = "Symbol_2Bar",		m_nSymbolType = 0,		m_frequency50 = {50}, 		m_frequency95 = {80}, 		m_frequency200 = {60}, 		m_fRewards = {0, 0, 8}},
		{nId = 3,	m_strPrefabName = "Symbol_3Bar",		m_nSymbolType = 0,		m_frequency50 = {40}, 		m_frequency95 = {70}, 		m_frequency200 = {60}, 		m_fRewards = {0, 0, 15}},

		{nId = 4,	m_strPrefabName = "Symbol_7Green",		m_nSymbolType = 0,		m_frequency50 = {40}, 		m_frequency95 = {60}, 		m_frequency200 = {60}, 		m_fRewards = {0, 0, 25}},
		{nId = 5,	m_strPrefabName = "Symbol_7Red",		m_nSymbolType = 0,		m_frequency50 = {30}, 		m_frequency95 = {20}, 		m_frequency200 = {60}, 		m_fRewards = {0, 0, 50}},

		{nId = 6,	m_strPrefabName = "Symbol_4Leaf",		m_nSymbolType = 1,		m_frequency50 = {5}, 		m_frequency95 = {10}, 		m_frequency200 = {60}, 		m_fRewards = {0, 0, 30}},
		{nId = 7,	m_strPrefabName = "Symbol_Wild",		m_nSymbolType = 1,		m_frequency50 = {30}, 		m_frequency95 = {10}, 		m_frequency200 = {60}, 		m_fRewards = {0, 0, 100}},
		{nId = 8,	m_strPrefabName = "Symbol_Gem",			m_nSymbolType = 1,		m_frequency50 = {10}, 		m_frequency95 = {10}, 		m_frequency200 = {60}, 		m_fRewards = {0, 0, 0}},
		{nId = 9,	m_strPrefabName = "Symbol_null",		m_nSymbolType = 2,		m_frequency50 = {0}, 		m_frequency95 = {0}, 		m_frequency200 = {0}, 		m_fRewards = {0, 0, 0}},
	}

}	


return IrishCFG
