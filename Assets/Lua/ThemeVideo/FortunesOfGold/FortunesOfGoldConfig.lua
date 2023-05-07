FortunesOfGoldConfig = {}

------------------- 测试 -------------------------
function FortunesOfGoldConfig:InitTestData()
    if not GameConfig.Instance.m_nThemeTestType then
        return
    end

    if GameConfig.Instance.m_nThemeTestType <= 0 then
        return
    end

    self.m_nThemeTestType = GameConfig.Instance.m_nThemeTestType
    Debug.Log("关卡 测试数据 加载: "..self.m_nThemeTestType)
    
    local bit1 = self.m_nThemeTestType & (1) -- 1: FreeSpin 测试
    local bit2 = self.m_nThemeTestType & (1<<1) -- 2: Bingo 测试
    local bit3 = self.m_nThemeTestType & (1<<2) -- 4: 正常 触发 白鸡蛋 测试

    self.m_bFreeSpinTest = false
    self.m_bBingGoTest = false
    self.m_bNormalTriggerBaiJiDanTest = false

    if bit1 ~= 0 then
        self.m_bFreeSpinTest = true
    end 

    if bit2 ~= 0 then
        self.m_bBingGoTest = true
    end 

    if bit3 ~= 0 then
        self.m_bNormalTriggerBaiJiDanTest = true
    end
    
end    

FortunesOfGoldConfig:InitTestData()
