TigerDragonConfig = {}

function TigerDragonConfig:GetFreeSpinCount()
    return 8
end

function TigerDragonConfig:orTriggerFreeSpin()   
    local rt = SlotsGameLua.m_GameResult
    if TigerDragonFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end
    
    local fTriggerRate = 0.0
    local returnType = ReturnRateManager.m_enumReturnRateType
    if rt:InFreeSpin() then
        fTriggerRate = 0.03
    else
        if returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
            fTriggerRate = 0.005
        elseif returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
            fTriggerRate = 0.01
        elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
            fTriggerRate = 0.02
        end
    end 
    
    if self.m_bFreeSpinTest then
        fTriggerRate = 0.5
    end

    local bTrigger = math.random() < fTriggerRate
    return bTrigger
end

-- 触发 FreeSpin Stack 的概率
function TigerDragonConfig:orTriggerWildSymbol()
    local tableTriggerRowRate = {9, 9, 9, 9, 9}
    local fTriggerRate = 0.5
    local returnType = ReturnRateManager.m_enumReturnRateType
    if returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
        fTriggerRate = 0.4
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
        fTriggerRate = 0.55
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
        fTriggerRate = 0.73
    end
    
    local bTrigger = math.random() < fTriggerRate
    local nRowIndex = LuaHelper.GetIndexByRate(tableTriggerRowRate) - 1
    return bTrigger, nRowIndex
end

------------------- 测试 -------------------------
function TigerDragonConfig:InitTestData()
    if not GameConfig.Instance.m_nThemeTestType then
        return
    end

    if GameConfig.Instance.m_nThemeTestType <= 0 then
        return
    end
    
    self.m_nThemeTestType = GameConfig.Instance.m_nThemeTestType
    Debug.Log("关卡 测试数据 加载: "..self.m_nThemeTestType)

    self.m_bFreeSpinTest = false
    self.m_bBonusGameTest = false
    self.m_bBonusGameTest = false

    if self.m_nThemeTestType == 1 then
        self.m_bFreeSpinTest = true
    end     
end    

TigerDragonConfig:InitTestData()