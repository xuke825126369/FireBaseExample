
local LuckyVegasCFG = {
	BasicInfo = {
		nReelCount = 5,	
		nRowCount = 3,
	},

	SymbolList = {
		{nId = 1,	m_strPrefabName = "vegas",		m_nSymbolType = 0,		m_frequency50 = {5}, 		m_frequency95 = {10}, 		m_frequency200 = {40}, 		m_fRewards = {0, 0, 100, 250, 1000}},
		{nId = 2,	m_strPrefabName = "7red",		m_nSymbolType = 0,		m_frequency50 = {10}, 		m_frequency95 = {10}, 		m_frequency200 = {40}, 		m_fRewards = {0, 0, 60, 150, 500}},
		{nId = 3,	m_strPrefabName = "7blue",		m_nSymbolType = 0,		m_frequency50 = {20}, 		m_frequency95 = {15}, 		m_frequency200 = {40}, 		m_fRewards = {0, 0, 50, 125, 400}},
		{nId = 4,	m_strPrefabName = "7green",		m_nSymbolType = 0,		m_frequency50 = {30}, 		m_frequency95 = {20}, 		m_frequency200 = {40}, 		m_fRewards = {0, 0, 40, 100, 300}},
		
		{nId = 5,	m_strPrefabName = "bar3",		m_nSymbolType = 0,		m_frequency50 = {30}, 		m_frequency95 = {40}, 		m_frequency200 = {60}, 		m_fRewards = {0, 0, 20, 50, 150}},
		{nId = 6,	m_strPrefabName = "bar2",		m_nSymbolType = 0,		m_frequency50 = {40}, 		m_frequency95 = {50}, 		m_frequency200 = {60}, 		m_fRewards = {0, 0, 18, 40, 125}},
		{nId = 7,	m_strPrefabName = "bar1",		m_nSymbolType = 0,		m_frequency50 = {50}, 		m_frequency95 = {60}, 		m_frequency200 = {60}, 		m_fRewards = {0, 0, 15, 30, 100}},
		
		{nId = 8,	m_strPrefabName = "bell",		m_nSymbolType = 0,		m_frequency50 = {90}, 		m_frequency95 = {68}, 		m_frequency200 = {72}, 		m_fRewards = {0, 0, 10, 20, 50}},
		{nId = 9,	m_strPrefabName = "grape",		m_nSymbolType = 0,		m_frequency50 = {100}, 		m_frequency95 = {78}, 		m_frequency200 = {72}, 		m_fRewards = {0, 0, 8, 15, 35}},
		{nId = 10,	m_strPrefabName = "cherry",		m_nSymbolType = 0,		m_frequency50 = {110}, 		m_frequency95 = {88}, 		m_frequency200 = {72}, 		m_fRewards = {0, 0, 5, 10, 25}},

		{nId = 11,	m_strPrefabName = "wild",		m_nSymbolType = 1,		m_frequency50 = {0, 1}, 	m_frequency95 = {0, 5}, 	m_frequency200 = {0, 40}, 	m_fRewards = {0, 0, 0, 0, 0}}, 
		{nId = 12,	m_strPrefabName = "scatter",	m_nSymbolType = 1,		m_frequency50 = {60}, 		m_frequency95 = {50}, 		m_frequency200 = {40},		m_fRewards = {0, 0, 0, 0, 0}},
	},

}

return LuckyVegasCFG
