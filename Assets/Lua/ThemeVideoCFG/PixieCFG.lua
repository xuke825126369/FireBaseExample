
local PixieCFG = {
	BasicInfo = {
		nReelCount = 5,	
		nRowCount = 4,
	},

	SymbolList = {
		{nId = 1,	m_strPrefabName = "Symbol_10",		m_nSymbolType = 0,		m_frequency50 = {60}, 				m_frequency95 = {50}, 				m_frequency200 = {40}, 				m_fRewards = {0, 0, 5, 10, 20}},
		{nId = 2,	m_strPrefabName = "Symbol_J",		m_nSymbolType = 0,		m_frequency50 = {60}, 				m_frequency95 = {50}, 				m_frequency200 = {40}, 				m_fRewards = {0, 0, 8, 15, 30}},
		{nId = 3,	m_strPrefabName = "Symbol_Q",		m_nSymbolType = 0,		m_frequency50 = {60}, 				m_frequency95 = {50}, 				m_frequency200 = {40}, 				m_fRewards = {0, 0, 8, 15, 30}},
		{nId = 4,	m_strPrefabName = "Symbol_K",		m_nSymbolType = 0,		m_frequency50 = {60}, 				m_frequency95 = {50}, 				m_frequency200 = {40}, 				m_fRewards = {0, 0, 10, 25, 50}},
		{nId = 5,	m_strPrefabName = "Symbol_A",		m_nSymbolType = 0,		m_frequency50 = {60}, 				m_frequency95 = {50}, 				m_frequency200 = {40}, 				m_fRewards = {0, 0, 10, 30, 80}},

		{nId = 6,	m_strPrefabName = "PixieBlueA_1",	m_nSymbolType = 1,		m_frequency50 = {20}, 				m_frequency95 = {20}, 				m_frequency200 = {20}, 				m_fRewards = {0, 3, 20, 50, 150}},
		{nId = 7,	m_strPrefabName = "PixieGreenB_1",	m_nSymbolType = 1,		m_frequency50 = {20}, 				m_frequency95 = {20}, 				m_frequency200 = {20}, 				m_fRewards = {0, 3, 20, 50, 150}},
		{nId = 8,	m_strPrefabName = "PixieRedC_1",	m_nSymbolType = 1,		m_frequency50 = {20}, 				m_frequency95 = {20}, 				m_frequency200 = {20}, 				m_fRewards = {0, 3, 20, 50, 150}},
		{nId = 9,	m_strPrefabName = "PixieYellowD_1",	m_nSymbolType = 1,		m_frequency50 = {20}, 				m_frequency95 = {20}, 				m_frequency200 = {20}, 				m_fRewards = {0, 3, 20, 50, 150}},
		
		{nId = 10,	m_strPrefabName = "Wild",			m_nSymbolType = 1,		m_frequency50 = {0, 0, 0, 0, 20}, 	m_frequency95 = {0, 0, 0, 0, 20}, 	m_frequency200 = {0, 0, 0, 0, 20}, 	m_fRewards = {0, 3, 20, 50, 150}},
		{nId = 11,	m_strPrefabName = "Scatter",		m_nSymbolType = 1,		m_frequency50 = {0, 0, 20}, 		m_frequency95 = {0, 0, 20}, 		m_frequency200 = {0, 0, 20}, 		m_fRewards = {0, 0, 0, 0, 0}},
		{nId = 12,	m_strPrefabName = "Symbol_null",	m_nSymbolType = 1,		m_frequency50 = {0}, 				m_frequency95 = {0}, 				m_frequency200 = {0}, 				m_fRewards = {0, 0, 0, 0, 0}},

	}
	
}	


return PixieCFG
