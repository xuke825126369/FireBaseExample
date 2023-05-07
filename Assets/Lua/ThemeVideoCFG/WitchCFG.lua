local WitchCFG = {
	BasicInfo = {
		nReelCount = 5,	
		nRowCount = 3,
	},

	SymbolList = {
		{nId = 1,	m_strPrefabName = "10",				m_nSymbolType = 0,	m_frequency50 = {9},	m_frequency95 = {9},		m_frequency200 = {90},		m_fRewards = {0, 0, 5, 10, 50}}, -- 10
		{nId = 2,	m_strPrefabName = "J",				m_nSymbolType = 0,	m_frequency50 = {9},	m_frequency95 = {9},		m_frequency200 = {90},		m_fRewards = {0, 0, 5, 10, 50}}, -- J
		{nId = 3,	m_strPrefabName = "Q",				m_nSymbolType = 0,	m_frequency50 = {9},	m_frequency95 = {9},		m_frequency200 = {90},		m_fRewards = {0, 0, 5, 10, 50}}, -- Q
		{nId = 4,	m_strPrefabName = "K",				m_nSymbolType = 0,	m_frequency50 = {9},	m_frequency95 = {9},		m_frequency200 = {90},		m_fRewards = {0, 0, 5, 10, 50}}, -- K
		{nId = 5,	m_strPrefabName = "A",				m_nSymbolType = 0,	m_frequency50 = {9},	m_frequency95 = {9},		m_frequency200 = {90},		m_fRewards = {0, 0, 5, 10, 50}}, -- A
		{nId = 6,	m_strPrefabName = "HONGYAOPING",	m_nSymbolType = 0,	m_frequency50 = {9},	m_frequency95 = {9},		m_frequency200 = {40},		m_fRewards = {0, 0, 5, 25, 100}}, -- 红药瓶
		{nId = 7,	m_strPrefabName = "JIEZHI",			m_nSymbolType = 0,	m_frequency50 = {9},	m_frequency95 = {9},		m_frequency200 = {40},		m_fRewards = {0, 0, 5, 25, 100}}, -- 戒指
		{nId = 8,	m_strPrefabName = "LVYAOPING",		m_nSymbolType = 0,	m_frequency50 = {9},	m_frequency95 = {9},		m_frequency200 = {40},		m_fRewards = {0, 0, 5, 20, 75}}, -- 绿药瓶
		{nId = 9,	m_strPrefabName = "maozi",			m_nSymbolType = 0,	m_frequency50 = {5},	m_frequency95 = {10},		m_frequency200 = {40},		m_fRewards = {0, 2, 10, 50, 150}}, -- 帽子
		{nId = 10,	m_strPrefabName = "mofashu",		m_nSymbolType = 0,	m_frequency50 = {9},	m_frequency95 = {9},		m_frequency200 = {40},		m_fRewards = {0, 0, 5, 25, 100}}, -- 魔法书

		{nId = 11,	m_strPrefabName = "Scatter",		m_nSymbolType = 1,	m_frequency50 = {9},	m_frequency95 = {9},		m_frequency200 = {9},		m_fRewards = {0, 0, 0, 0, 0}}, -- scatter
		{nId = 12,	m_strPrefabName = "Wild",			m_nSymbolType = 1,	m_frequency50 = {9},	m_frequency95 = {9},		m_frequency200 = {9},		m_fRewards = {0, 0, 10, 50, 200}}, -- wild
		{nId = 13,	m_strPrefabName = "ReSpinCollect",	m_nSymbolType = 1,	m_frequency50 = {9},	m_frequency95 = {9},		m_frequency200 = {9},		m_fRewards = {0, 0, 0, 0, 0}}, -- 收集元素
	},
	
}

return WitchCFG
