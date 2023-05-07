LuckyVegasConfig = {}

LuckyVegasConfig.TABLE_ANY_BAR_MULTUILE = {0, 0, 12, 25, 75}
LuckyVegasConfig.TABLE_ANY_7_MULTUILE = {0, 0, 30, 75, 200}
LuckyVegasConfig.TABLE_JACKPOT_MIN_MULTUILE = {30.0, 15.0, 10.0, 8.0, 6.0, 5.0, 4.0, 3.0, 2.0, 1.0} -- 最小倍数
LuckyVegasConfig.TABLE_JACKPOT_ADDCOEF = {0.008, 0.008, 0.008, 0.008, 0.008, 0.008, 0.008, 0.008, 0.008, 0.008} -- 增长系数

function LuckyVegasConfig:orTriggerFreeSpin()
    local rt = SlotsGameLua.m_GameResult
    if LuckyVegasFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end     
    
    local fTriggerRate = 0.0
    local tableTriggerScatterCount = {}
    if rt:InFreeSpin() then
        fTriggerRate = 0.01
        tableTriggerScatterCount = {0, 1, 1, 1}
    else
        tableTriggerScatterCount = {0, 0, 50, 20, 1}
        if ReturnRateManager.m_enumReturnRateType == enumReturnRateTYPE.enumReturnType_Rate50 then
            fTriggerRate = 0.001
        elseif ReturnRateManager.m_enumReturnRateType == enumReturnRateTYPE.enumReturnType_Rate95 then
            fTriggerRate = 0.005
        elseif ReturnRateManager.m_enumReturnRateType == enumReturnRateTYPE.enumReturnType_Rate200 then
            fTriggerRate = 0.01
        else
            Debug.Assert(false)
        end 

        if self.m_bFreeSpinTest then
            fTriggerRate = 0.5
        end
    end  

    local bTrigger = math.random() < fTriggerRate
    local nTriggerCount = LuaHelper.GetIndexByRate(tableTriggerScatterCount)
    return bTrigger, nTriggerCount
end

function LuckyVegasConfig:GetFreeSpinCount(nScatterCount)
    local rt = SlotsGameLua.m_GameResult
    if LuckyVegasFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end 

    if rt:InFreeSpin() then
        if nScatterCount == 2 then
            return 5
        elseif nScatterCount == 3 then
            return 7
        elseif nScatterCount == 4 then
            return 11
        end
    else
        if nScatterCount == 3 then
            return 7
        elseif nScatterCount == 4 then
            return 11
        elseif nScatterCount == 5 then
            return 21
        end
    end

    Debug.Assert(false)
end

------------------- 测试 -------------------------
function LuckyVegasConfig:InitTestData()
    if not GameConfig.Instance.m_nThemeTestType then
        return
    end

    if GameConfig.Instance.m_nThemeTestType <= 0 then
        return
    end 

    self.m_nThemeTestType = GameConfig.Instance.m_nThemeTestType
    Debug.Log("关卡 测试数据 加载: "..self.m_nThemeTestType)

    self.m_bFreeSpinTest = false
    self.m_bJackPotTest = false

    if self.m_nThemeTestType == 1 then
        self.m_bFreeSpinTest = true
    end  

    if self.m_nThemeTestType == 2 then
        self.m_bJackPotTest = true
    end

end    

LuckyVegasConfig:InitTestData()