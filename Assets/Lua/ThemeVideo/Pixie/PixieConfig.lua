PixieConfig = {}

PixieConfig.TABLE_JACKPOT_MIN_MULTUILE = {20, 50, 100, 500} -- 最小倍数
PixieConfig.TABLE_JACKPOT_ADDCOEF = {0.001, 0.002, 0.003, 0.004} -- 增长系数

function PixieConfig:GetFreeSpinCount()
    return 6
end

function PixieConfig:orTriggerFreeSpin()
    local fTriggerRate = 0.0
    local returnType = ReturnRateManager.m_enumReturnRateType
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

    local bTrigger = math.random() < fTriggerRate
    return bTrigger
end

function PixieConfig:GetBigSymbolId()
    local tableSymbolRate = {1, 1, 1, 1}
    local nIndex = LuaHelper.GetIndexByRate(tableSymbolRate)
    if nIndex == 1 then
        return SlotsGameLua:GetSymbolIdByObjName("PixieBlueA_1")
    elseif nIndex == 2 then
        return SlotsGameLua:GetSymbolIdByObjName("PixieGreenB_1")
    elseif nIndex == 3 then
        return SlotsGameLua:GetSymbolIdByObjName("PixieRedC_1")
    elseif nIndex == 4 then
        return SlotsGameLua:GetSymbolIdByObjName("PixieYellowD_1")
    else
        Debug.Assert(false)
    end
end

-- 触发 FreeSpin Stack 的概率
function PixieConfig:orTriggerBigSymbol(nReelId)
    local tableTriggerRowRate = {9, 9, 9, 9, 9, 9, 9}
    local tableTriggerReelRate = {0, 0, 0, 0, 0} -- 5列 分别的触发概率

    local returnType = ReturnRateManager.m_enumReturnRateType
    if returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
        tableTriggerRowRate =  {9, 9, 9, 9, 9, 9, 9}
        tableTriggerReelRate = {0.2, 0.2, 0.2, 0.2, 0.2}
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
        tableTriggerRowRate =  {9, 9, 9, 9, 9, 9, 9}
        tableTriggerReelRate = {0.4, 0.4, 0.4, 0.4, 0.4}
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
        tableTriggerRowRate =  {9, 9, 9, 9, 9, 9, 9}
        tableTriggerReelRate = {0.6, 0.6, 0.6, 0.6, 0.6}
    end 

    local bTrigger =  math.random() < tableTriggerReelRate[nReelId + 1]
    local nRowIndex = LuaHelper.GetIndexByRate(tableTriggerRowRate) - 1
    return bTrigger, nRowIndex
end

function PixieConfig:orTriggerWildSymbol()
    local fTriggerRate = 0
    local returnType = ReturnRateManager.m_enumReturnRateType
    if returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
        fTriggerRate = 0.27
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
        fTriggerRate = 0.45
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
        fTriggerRate = 0.7
    end
    
    if self.m_bTriggerWildTest then
        fTriggerRate = 0.5
    end

    local bTrigger = math.random() < fTriggerRate
    return bTrigger
end

------------------- 测试 -------------------------
function PixieConfig:InitTestData()
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

PixieConfig:InitTestData()