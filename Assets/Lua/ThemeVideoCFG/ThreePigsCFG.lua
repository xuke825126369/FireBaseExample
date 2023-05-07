
local ThreePigsCFG = {
	BasicInfo = {
		nReelCount = 5,	
		nRowCount = 3,
	},	
	
	SymbolList = {
		{nId = 1,	m_strPrefabName = "10",			m_nSymbolType = 0,		m_frequency50 = {60}, 					m_frequency95 = {60}, 					m_frequency200 = {60}, 					m_fRewards = {0, 0, 5, 10, 30}},
		{nId = 2,	m_strPrefabName = "J",			m_nSymbolType = 0,		m_frequency50 = {60}, 					m_frequency95 = {60}, 					m_frequency200 = {60}, 					m_fRewards = {0, 0, 5, 10, 30}},
		{nId = 3,	m_strPrefabName = "Q",			m_nSymbolType = 0,		m_frequency50 = {60}, 					m_frequency95 = {60}, 					m_frequency200 = {60}, 					m_fRewards = {0, 0, 5, 10, 30}},
		{nId = 4,	m_strPrefabName = "K",			m_nSymbolType = 0,		m_frequency50 = {60}, 					m_frequency95 = {60}, 					m_frequency200 = {60}, 					m_fRewards = {0, 0, 5, 15, 40}},
		{nId = 5,	m_strPrefabName = "A",			m_nSymbolType = 0,		m_frequency50 = {60}, 					m_frequency95 = {60}, 					m_frequency200 = {60}, 					m_fRewards = {0, 0, 5, 15, 40}},

		{nId = 6,	m_strPrefabName = "apple",		m_nSymbolType = 0,		m_frequency50 = {60}, 					m_frequency95 = {60}, 					m_frequency200 = {60}, 					m_fRewards = {0, 0, 10, 30, 60}},
		{nId = 7,	m_strPrefabName = "butter",		m_nSymbolType = 0,		m_frequency50 = {60}, 					m_frequency95 = {60}, 					m_frequency200 = {60}, 					m_fRewards = {0, 0, 10, 30, 60}},
		{nId = 8,	m_strPrefabName = "carrot",		m_nSymbolType = 0,		m_frequency50 = {60}, 					m_frequency95 = {60}, 					m_frequency200 = {60}, 					m_fRewards = {0, 0, 10, 30, 60}},
		
		{nId = 9,	m_strPrefabName = "pig1",		m_nSymbolType = 1,		m_frequency50 = {26}, 					m_frequency95 = {40}, 					m_frequency200 = {60}, 					m_fRewards = {0, 3, 15, 50, 100}},
		{nId = 10,	m_strPrefabName = "pig2",		m_nSymbolType = 1,		m_frequency50 = {26}, 					m_frequency95 = {40}, 					m_frequency200 = {60}, 					m_fRewards = {0, 3, 20, 60, 125}},
		{nId = 11,	m_strPrefabName = "pig3",		m_nSymbolType = 1,		m_frequency50 = {26}, 					m_frequency95 = {40}, 					m_frequency200 = {60}, 					m_fRewards = {0, 3, 30, 100, 200}},

		{nId = 12,	m_strPrefabName = "wild",		m_nSymbolType = 1,		m_frequency50 = {0, 19}, 				m_frequency95 = {0, 20}, 				m_frequency200 = {0, 60}, 				m_fRewards = {0, 0, 0, 0, 0}},
		{nId = 13,	m_strPrefabName = "scatter",	m_nSymbolType = 1,		m_frequency50 = {0, 60, 60, 60, 0}, 	m_frequency95 = {0, 60, 60, 60, 0}, 	m_frequency200 = {0, 60, 60, 60, 0}, 	m_fRewards = {0, 0, 0, 0, 0}},
	}	

}	


return ThreePigsCFG
