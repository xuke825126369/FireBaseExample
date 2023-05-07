RedHatConfig = {}

RedHatConfig.TABLE_BONUS_MAX_COLLECT_COUNT = {100, 200, 300, 400, 500, 600, 700, 800, 900}
RedHatConfig.TABLE_BONUS_INIT_FREECOUNT = {5, 10, 15, 20, 25, 30, 35, 40, 45}
RedHatConfig.TABLE_BONUS_MAX_FREE_SPIN_COUNT = {10, 20, 30, 40, 50, 60, 70, 80, 90}

RedHatConfig.TABLE_BONUS_FEATURE_FIXED_WILD_KEYS = {
    [1] = {8, 20},
    [2] = {4, 14, 24},
    [3] = {6, 14, 22},
    [4] = {0, 4, 24, 28},
    [5] = {2, 12, 16, 26},
    [6] = {0, 2, 4},
    [7] = {4, 12, 16, 24},
    [8] = {6, 10, 18, 22},
    [9] = {2, 14, 26},
}

function RedHatConfig:GetFreeSpinCount(nScatterCount)
    local nFreeSpinCount = 5 + (nScatterCount - 4) * 5
    if nFreeSpinCount >= 60 then
        nFreeSpinCount = 60
    end
    return nFreeSpinCount
end

function RedHatConfig:orTriggerFreeSpin()
    local rt = SlotsGameLua.m_GameResult
    if RedHatFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end     
    
    local fTriggerRate = 0.0
    local tableCountRate = {
        0, 0, 0, 0, 1024,
        512, 256, 128, 64, 32,
        16, 8, 4, 2, 1,
    }

    local returnType = ReturnRateManager.m_enumReturnRateType
    if rt:InFreeSpin() then
        fTriggerRate = 0.01
    else
        if returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
            fTriggerRate = 0.005
        elseif returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
            fTriggerRate = 0.01
        elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
            fTriggerRate = 0.02
        end
        
        if self.m_bFreeSpinTest then
            fTriggerRate = 0.5
        end
    end

    local bTrigger = math.random() < fTriggerRate
    local nTriggerCount = LuaHelper.GetIndexByRate(tableCountRate)
    return bTrigger, nTriggerCount
end

function RedHatConfig:orTriggerWildSymbol()
    local rt = SlotsGameLua.m_GameResult
    if RedHatFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local fTriggerRate = 0.0
    local tableCountRate = {1, 1, 1, 1, 1, 1}
    local nWildCount = 0
    local returnType = ReturnRateManager.m_enumReturnRateType
    if rt:InFreeSpin() then
        
    else
        if returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
            fTriggerRate = 0.3
            tableCountRate = {6, 5, 4, 3, 2, 1}
        elseif returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
            fTriggerRate = 0.55
            tableCountRate = {6, 5, 4, 3, 2, 1}
        elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
            fTriggerRate = 0.8
            tableCountRate = {6, 5, 4, 3, 2, 1}
        end
    end         

    if self.m_bTriggerWildTest then
        fTriggerRate = 0.5
    end

    local bTrigger = math.random() < fTriggerRate
    local nWildCount = LuaHelper.GetIndexByRate(tableCountRate)
    return bTrigger, nWildCount
end

function RedHatConfig:GetWildSymbolTriggerFreeSpinCount()
    local tableCountRate = {200, 8, 4, 2}
    local nCount = LuaHelper.GetIndexByRate(tableCountRate) - 1
    return nCount
end

------------------- 测试 -------------------------
function RedHatConfig:InitTestData()
    if not GameConfig.Instance.m_nThemeTestType then
        return
    end

    if GameConfig.Instance.m_nThemeTestType <= 0 then
        return
    end

    self.m_nThemeTestType = GameConfig.Instance.m_nThemeTestType
    Debug.Log("关卡 测试数据 加载: "..self.m_nThemeTestType)

    self.m_bFreeSpinTest = false
    self.m_bTriggerWildTest = false
    if self.m_nThemeTestType == 1 then
        self.m_bFreeSpinTest = true
    end     

    if self.m_nThemeTestType == 2 then
        self.m_bTriggerWildTest = true
    end 
end    

RedHatConfig:InitTestData()