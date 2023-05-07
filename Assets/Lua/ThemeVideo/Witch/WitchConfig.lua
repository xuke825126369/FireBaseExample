WitchConfig = {}

-- 10 J Q K A HONGYAOPING JIEZHI LVYAOPING 
-- maozi mofashu Scatter Wild ReSpinCollect NullSymbol
WitchConfig.FREESPIN_SYMBOL_AWARD_MULTUILE = {
    {0, 0, 0, 5, 15}, {0, 0, 0, 5, 15}, {0, 0, 0, 5, 15}, {0, 0, 0, 5, 15},
    {0, 0, 0, 5, 15}, {0, 0, 0, 10, 25}, {0, 0, 0, 10, 25}, {0, 0, 0, 5, 20},
    {0, 0, 0, 10, 100}, {0, 0, 0, 10, 50}, {0, 0, 0, 0, 0}, {0, 0, 0, 10, 100},
    {0, 0, 0, 0, 0}, {0, 0, 0, 0, 0},
}

---------------- FreeSpin 相关配置 ------------------
WitchConfig.N_FREESPIN_TRIGGER_MIN_SCATTERCOUNT = 3
WitchConfig.TABLE_FREESPIN_TRIGGER_FREECOUNT = {0, 0, 6, 10, 18}

---------------- ReSpin 相关配置 ------------------
WitchConfig.N_RESPIN_TRIGGER_MIN_COLLECTCOUNT = 6
WitchConfig.TABLE_RESPIN_COLLECT_MONEY_MULTUILE = {1, 1.5, 2, 2.5, 3, 3.5, 4}
WitchConfig.N_RESPIN_TRIGGER_FREECOUNT = 3

---------------- JackPot 相关配置 -------------------
WitchConfig.TABLE_JACKPOT_MIN_MULTUILE = {5, 10, 50, 200} -- 最小倍数
WitchConfig.TABLE_JACKPOT_ADDCOEF = {0.002, 0.003, 0.004, 0.005} -- 增长系数
WitchConfig.F_JACKPOT_GRAND_UNLOCK_MIN_BETVALUE = 10000000

---------------- 转盘 相关配置 -------------------

-- 触发FreeSpin 的概率
function WitchConfig:orFreeSpinTrigger()
    local rt = SlotsGameLua.m_GameResult
    if WitchFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local bReSpinFlag = rt:InReSpin()
    local bFreeSpinFlag = rt:InFreeSpin()

    local fTriggerProb = 0.0 -- 触发Freespin的概率
    local tableTriggerCount = {0, 0, 1, 1, 1}

    if bFreeSpinFlag then
        -- 在 FreeSpin 里 触发的概率
        local returnType = ReturnRateManager.m_enumReturnRateType
        if returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
            fTriggerProb = 0.01
            tableTriggerCount = {0, 0, 80, 20, 5}
        elseif returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
            fTriggerProb = 0.01
            tableTriggerCount = {0, 0, 80, 20, 5}
        elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
            fTriggerProb = 0.01
            tableTriggerCount = {0, 0, 80, 20, 5}
        end
    else
        -- 不在 FreeSpin 里 触发的概率
        local returnType = ReturnRateManager.m_enumReturnRateType
        if returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
            fTriggerProb = 0.008
            tableTriggerCount = {0, 0, 80, 20, 10}
        elseif returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
            fTriggerProb = 0.01
            tableTriggerCount = {0, 0, 80, 20, 10}
        elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
            fTriggerProb = 0.016
            tableTriggerCount = {0, 0, 80, 60, 20}
        else
            Debug.Assert(false)
        end

        if self.m_bFreeSpinTest then
            fTriggerProb = 0.3
        end 
    end

    return math.random() < fTriggerProb, LuaHelper.GetIndexByRate(tableTriggerCount)
end

-------------------------- ReSpin  ----------------------------
--ReSpin 触发
function WitchConfig:orReSpinTrigger() 
    local fTriggerProb = 0.0 -- 触发respin的概率
    local tableTriggerCount = {0, 0, 0, 0, 0, 1, 1, 1, 1}

    local returnType = ReturnRateManager.m_enumReturnRateType
    if returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
        fTriggerProb = 0.008
        tableTriggerCount = {0, 0, 0, 0, 0, 100, 50, 10, 2}
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
        fTriggerProb = 0.01
        tableTriggerCount = {0, 0, 0, 0, 0, 150, 50, 10, 2}
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
        fTriggerProb = 0.016
        tableTriggerCount = {0, 0, 0, 0, 0, 100, 50, 10, 2}
    end
    
    if self.m_bReSpinTest or self.m_bReSpinFullTest then
        fTriggerProb = 0.3
    end 

    return math.random() < fTriggerProb, LuaHelper.GetIndexByRate(tableTriggerCount)
end

-- ReSpin 增加收集的元素的概率
function WitchConfig:orReSpinAddCollectElem()
    local fTriggerProb = 0.0
    local tableTriggerCountRate = {1, 1, 1}

    local listCollectValue = {9, 13}
    local listProb = {0.4, 0.3, 0.2}

    local returnType = ReturnRateManager.m_enumReturnRateType
    if returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
        listCollectValue = {8, 12}
        listProb = {0.6, 0.5, 0.1}

        tableTriggerCountRate = {600, 10, 10}
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
        listCollectValue = {8, 12}
        listProb = {0.65, 0.5, 0.1}

        tableTriggerCountRate = {600, 60, 10}
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
        listCollectValue = {8, 12}
        listProb = {0.7, 0.5, 0.2}

        tableTriggerCountRate = {500, 100, 10}
    end

    -- 当前盘面上已经固定几个了..
    local nNowCollectElementCount = LuaHelper.tableSize(WitchFunc.tableReSpinFixedCollectSymbol)
    if nNowCollectElementCount < listCollectValue[1] then
        fTriggerProb = listProb[1]
    elseif nNowCollectElementCount < listCollectValue[2] then
        fTriggerProb = listProb[2]
    else
        fTriggerProb = listProb[3]
    end

    if self.m_bReSpinFullTest then
        fTriggerProb = 1.0
    end

    return math.random() < fTriggerProb, LuaHelper.GetIndexByRate(tableTriggerCountRate)
end

-- 得到ReSpin的收集类型
function WitchConfig:GetReSpinCollectType()
    -- 1:Mini, 2:Minor, 3: Major, 4:Money
    local tableTypeRate = {15, 10, 5, 350}

    local nType = LuaHelper.GetIndexByRate(tableTypeRate)
    
    local nMoneyMultuile = 0
    if nType == 4 then
        local tableMoneyMultuileRate = {180, 80, 60, 50, 30, 20, 10}
        
        local nIndex = LuaHelper.GetIndexByRate(tableMoneyMultuileRate)
        nMoneyMultuile = self.TABLE_RESPIN_COLLECT_MONEY_MULTUILE[nIndex]
    end

    return nType, nMoneyMultuile
end

-- 得到中间大元素的概率
function WitchConfig:GetFreeSpinReSpinMiddleCollectType()
    -- 1:Mini, 2:Minor, 3: Major, 4:Money
    local tableTypeRate = {30, 60, 80, 30}
    local nType = LuaHelper.GetIndexByRate(tableTypeRate)

    local nMoneyMultuile = 0
    if nType == 4 then
        local tableMoneyMultuileRate = {2, 5, 10, 50, 60, 70, 80}
        local nIndex = LuaHelper.GetIndexByRate(tableMoneyMultuileRate)
        nMoneyMultuile = self.TABLE_RESPIN_COLLECT_MONEY_MULTUILE[nIndex]
    end
    
    return nType, nMoneyMultuile
end

-- Wild 成列
function WitchConfig:orTriggeWildStack(nReelId)
    local tableTriggerRowRate = {0, 0, 0, 0, 0, 0} -- 6行的占比
    local tableTriggerReelRate = {0, 0, 0, 0, 0} -- 5列 分别的触发概率

    -- 成列的 wild 掉落概率
    local returnType = ReturnRateManager.m_enumReturnRateType
    if returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
        tableTriggerRowRate = {5, 3, 2, 3, 5, 0}
        tableTriggerReelRate = {0.1, 0.1, 0.2, 0.2, 0.3}
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
        tableTriggerRowRate = {5, 3, 2, 3, 5, 0}
        tableTriggerReelRate = {0.2, 0.3, 0.3, 0.3, 0.2}
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
        tableTriggerRowRate = {6, 8, 9, 8, 6, 0}
        tableTriggerReelRate = {0.3, 0.35, 0.26, 0.3, 0.25}
    end
    
    local bTrigger = math.random() < tableTriggerReelRate[nReelId + 1]
    local nRowIndex = LuaHelper.GetIndexByRate(tableTriggerRowRate) - 1
    return bTrigger, nRowIndex
end

------------------- 测试 -------------------------
function WitchConfig:InitTestData()
    if not GameConfig.Instance.m_nThemeTestType then
        return
    end

    if GameConfig.Instance.m_nThemeTestType <= 0 then
        return
    end 

    self.m_nThemeTestType = GameConfig.Instance.m_nThemeTestType
    Debug.Log("关卡 测试数据 加载: "..self.m_nThemeTestType)

    local bit1 = self.m_nThemeTestType & 1 -- freespin 测试
    local bit2 = self.m_nThemeTestType & (1<<1) -- ReSpin 测试
    local bit3 = self.m_nThemeTestType & (1<<2) -- ReSpin 测试

    self.m_bFreeSpinTest = false
    self.m_bReSpinTest = false
    self.m_bReSpinFullTest = false

    if bit1 ~= 0 then
        self.m_bFreeSpinTest = true
    end

    if bit2 ~= 0 then
        self.m_bReSpinTest = true
    end

    if bit3 ~= 0 then
        self.m_bReSpinFullTest = true
    end

end     

WitchConfig:InitTestData()
