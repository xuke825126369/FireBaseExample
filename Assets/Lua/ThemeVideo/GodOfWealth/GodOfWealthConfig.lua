GodOfWealthConfig = {}

function GodOfWealthConfig:GetFreeSpinCount(nScatterCount)
    local rt = SlotsGameLua.m_GameResult
    if GodOfWealthFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end     

    if rt:InFreeSpin() then
        if nScatterCount == 2 then
            return 3
        elseif nScatterCount == 3 then
            return 10
        elseif nScatterCount == 4 then
            return 15
        elseif nScatterCount == 5 then
            return 25
        else
            Debug.Assert(false)
        end
    else
        if nScatterCount == 3 then
            return 10
        elseif nScatterCount == 4 then
            return 15
        elseif nScatterCount == 5 then
            return 25
        elseif nScatterCount == 6 then
            return 50
        else
            Debug.Assert(false)
        end
    end

end

function GodOfWealthConfig:orTriggerFreeSpin()
    local rt = SlotsGameLua.m_GameResult
    if GodOfWealthFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end     

    local fTriggerRate = 0.0
    local tableTriggerScatterCountRate = {0, 0, 1, 1, 1}
    local returnType = ReturnRateManager.m_enumReturnRateType

    if rt:InFreeSpin() then
        fTriggerRate = 0.01
        tableTriggerScatterCountRate = {0, 1, 1, 1, 1}
    else
        if returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
            fTriggerRate = 0.005
            tableTriggerScatterCountRate = {0, 0, 100, 50, 10}
        elseif returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
            fTriggerRate = 0.01
            tableTriggerScatterCountRate = {0, 0, 100, 70, 40}
        elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
            fTriggerRate = 0.02
            tableTriggerScatterCountRate = {0, 0, 100, 100, 100}
        end
        
        if self.m_bFreeSpinTest then
            fTriggerRate = 0.5
        end
    end
    
    local bTrigger = math.random() < fTriggerRate
    local nScatterCount = LuaHelper.GetIndexByRate(tableTriggerScatterCountRate)
    return bTrigger, nScatterCount
end

------------------- 测试 -------------------------
function GodOfWealthConfig:InitTestData()
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

    if self.m_nThemeTestType == 1 then
        self.m_bFreeSpinTest = true
    end     
end    

GodOfWealthConfig:InitTestData()