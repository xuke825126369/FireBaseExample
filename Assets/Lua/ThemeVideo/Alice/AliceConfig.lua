AliceConfig = {}

-- 触发 FreeSpin Wild Stack 的概率
function AliceConfig:orTriggerAliceSymbol(nReelId)
    local tableTriggerRowRate = {9, 9, 9, 9, 9, 9, 9, 9, 9, 9}
    local tableTriggerReelRate = {0, 0, 0, 0, 0, 0} -- 5列 分别的触发概率

    local returnType = ReturnRateManager.m_enumReturnRateType
    if returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
        tableTriggerRowRate = {9, 9, 9, 9, 9, 9, 9, 9, 9, 9}
        tableTriggerReelRate = {0.15, 0.15, 0.15, 0.15, 0.15, 0.15}
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
        tableTriggerRowRate = {9, 9, 9, 9, 9, 9, 9, 9, 9, 9}
        tableTriggerReelRate =  {0.2, 0.2, 0.2, 0.2, 0.2, 0.2}
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
        tableTriggerRowRate = {9, 9, 9, 9, 9, 9, 9, 9, 9, 9}
        tableTriggerReelRate =  {0.3, 0.3, 0.3, 0.3, 0.3, 0.3}
    end

    local bTrigger =  math.random() < tableTriggerReelRate[nReelId + 1]
    local nRowIndex = LuaHelper.GetIndexByRate(tableTriggerRowRate) - 1
    return bTrigger, nRowIndex
end

function AliceConfig:orTriggerFreeSpin()
    local rt = SlotsGameLua.m_GameResult
    if AliceFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local fTriggerRate = 0.0
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
    return bTrigger
end

function AliceConfig:GetTriggerFreeSpinFeatureType()
    --1: Free Spin Bonus X3  --2: Cat Feature --3: Alice Feature
    local tableTypeRate = {1, 1, 1}
    return LuaHelper.GetIndexByRate(tableTypeRate)
end

-- 触发 FreeSpin Wild Stack 的概率
function AliceConfig:orTriggerWildStackSymbol(nReelId)
    local tableTriggerRowRate = {9, 9, 9, 9, 9, 9, 9, 9, 9}
    local tableTriggerReelRate = {0, 0, 0, 0, 0, 0} -- 5列 分别的触发概率

    local returnType = ReturnRateManager.m_enumReturnRateType
    if returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
        tableTriggerRowRate =  {9, 9, 9, 9, 9, 9, 9, 9, 9}
        tableTriggerReelRate = {0.4, 0.4, 0.4, 0.4, 0.4}
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
        tableTriggerRowRate =  {9, 9, 9, 9, 9, 9, 9, 9, 9}
        tableTriggerReelRate = {0.5, 0.5, 0.5, 0.5, 0.5}
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
        tableTriggerRowRate =  {9, 9, 9, 9, 9, 9, 9, 9, 9}
        tableTriggerReelRate = {0.6, 0.6, 0.6, 0.6, 0.6}
    end

    local bTrigger =  math.random() < tableTriggerReelRate[nReelId + 1]
    local nRowIndex = LuaHelper.GetIndexByRate(tableTriggerRowRate) - 1
    return bTrigger, nRowIndex
end

------------------- 测试 -------------------------
function AliceConfig:InitTestData()
    if not GameConfig.Instance.m_nThemeTestType then
        return
    end

    if GameConfig.Instance.m_nThemeTestType <= 0 then
        return
    end

    self.m_nThemeTestType = GameConfig.Instance.m_nThemeTestType
    Debug.Log("关卡 测试数据 加载: "..self.m_nThemeTestType)

    local bit1 = self.m_nThemeTestType & (1) -- 1: FreeSpin 测试
    self.m_bFreeSpinTest = false

    if bit1 ~= 0 then
        self.m_bFreeSpinTest = true
    end
    
end    

AliceConfig:InitTestData()