AfricaManiaConfig = {}

function AfricaManiaConfig:GetFreeSpinCount(nScatterCount)
    if nScatterCount == 10 then
        return 10
    elseif nScatterCount == 11 then
        return 15
    elseif nScatterCount == 12 then
        return 20
    elseif nScatterCount == 13 then
        return 25
    elseif nScatterCount == 14 then
        return 30
    elseif nScatterCount == 15 then
        return 35
    elseif nScatterCount == 16 then
        return 40
    elseif nScatterCount == 17 then
        return 45
    elseif nScatterCount == 18 then
        return 50
    elseif nScatterCount == 19 then
        return 100
    elseif nScatterCount >= 20 then
        return 250
    end
    
    return 0
end

function AfricaManiaConfig:orTriggerFreeSpin()
    local fTriggerRate = 0.05
    local tableCountRate = {
        512, 256, 128, 64, 32,
        16, 8, 4, 2, 1
    }
    
    local returnType = ReturnRateManager.m_enumReturnRateType
    if returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
        fTriggerRate = 0.005
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
        fTriggerRate = 0.01
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
        fTriggerRate = 0.02
    else
        Debug.Assert(false)
    end 

    if self.m_bFreeSpinTest then
        fTriggerRate = 0.6
    end 

    local bTrigger = math.random() < fTriggerRate
    local nScatterCount = LuaHelper.GetIndexByRate(tableCountRate) + 9
    return bTrigger, nScatterCount
end

-- 触发 FreeSpin Wild Stack 的概率
function AfricaManiaConfig:CheckWildStack(nReelId)
    local rt = SlotsGameLua.m_GameResult
    if AfricaManiaFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local tableTriggerRowRate = {0, 0, 0, 0, 0, 0, 0, 0}
    local tableTriggerReelRate = {0, 0, 0, 0, 0, 0} -- 5列 分别的触发概率

    local returnType = ReturnRateManager.m_enumReturnRateType
    if returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
        tableTriggerRowRate = {9, 9, 9, 9, 9, 9, 9, 9}
        tableTriggerReelRate = {0.1, 0.1, 0.1, 0.1, 0.1, 0.1}
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
        tableTriggerRowRate = {9, 9, 9, 9, 9, 9, 9, 9}
        tableTriggerReelRate =  {0.2, 0.2, 0.2, 0.2, 0.2, 0.2}
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
        tableTriggerRowRate = {9, 9, 9, 9, 9, 9, 9, 9}
        tableTriggerReelRate =  {0.3, 0.3, 0.3, 0.3, 0.3, 0.3}
    end

    local bTrigger =  math.random() < tableTriggerReelRate[nReelId + 1]
    local nRowIndex = LuaHelper.GetIndexByRate(tableTriggerRowRate) - 1
    return bTrigger, nRowIndex
end

------------------- 测试 -------------------------
function AfricaManiaConfig:InitTestData()
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

AfricaManiaConfig:InitTestData()