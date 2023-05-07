ThreePigsConfig = {}

ThreePigsConfig.N_COLLECT_MAX_COUNT = 50
ThreePigsConfig.TABLE_JACKPOT_MIN_MULTUILE = {150} -- 最小倍数
ThreePigsConfig.TABLE_JACKPOT_ADDCOEF = {0.001} -- 增长系数

function ThreePigsConfig:orTriggerFreeSpin()
    local rt = SlotsGameLua.m_GameResult
    if ThreePigsFunc.m_bSimulationFlag then
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

------------------- 测试 -------------------------
function ThreePigsConfig:InitTestData()
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

ThreePigsConfig:InitTestData()