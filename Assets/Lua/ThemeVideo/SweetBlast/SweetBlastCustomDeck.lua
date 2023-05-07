SweetBlastCustomDeck = {}

SweetBlastCustomDeck.m_bFreeSpinTest = false -- freespin 测试 1
SweetBlastCustomDeck.m_bRespinTest = false -- respin 测试 2
SweetBlastCustomDeck.m_bCollectTest = false -- 收集 测试 4

-- 用于程序做一些精确控制 比如什么时候触发freespin  respin等等。。。。。

function SweetBlastCustomDeck:checkDeckForBonusGame(deck)
    local bTriggerReSpin = SweetBlastFunc:isTriggerRespin(deck)
    if bTriggerReSpin then
        return deck
    end
    
    local nBonusGameID = SlotsGameLua:GetSymbolIdByObjName("Bonus")

    local bTriggerBonusGameFlag, nBonus = self:isNeedTriggerBonusGame()
    if not bTriggerBonusGameFlag then
        local bTriggerFlag = SweetBlastFunc:isTriggerBonusGame(deck)
        if bTriggerFlag then
            -- 不该触发的情况下随机掉落导致触发了。。
            -- 把盘面的bonus牌去掉。。
            for key=0, 19 do
                if deck[key] == nBonusGameID then
                    deck[key] = math.random(1, 8)
                end
            end

        end

        return deck
    end
    
    -- 以下是程序控制应该触发了的情况。。
    for key=0, 19 do -- 先把盘面的bonus牌去掉。。
        if deck[key] == nBonusGameID then
            deck[key] = math.random(1, 8)
        end
    end

    -- 往盘面上布置 nBonus 个 bonus 元素 （ nBonusGameID ）
    local listReels = {0, 1, 2, 3, 4}
    listReels = LuaThemeVideo2020Helper.shuffle(listReels)
    for i=1, nBonus do
        local reelIndex = listReels[i]
        local nRandom = math.random(0, 3)
        local nkey = reelIndex * 4 + nRandom
        deck[nkey] = nBonusGameID
    end
    
    return deck
end

-- 一定概率修改触发 respin
function SweetBlastCustomDeck:modifyDeckForRespin(deck)
    local rt = SlotsGameLua.m_GameResult
    if SweetBlastFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local bFreeSpinFlag = rt:InFreeSpin()
    if bFreeSpinFlag then
        return deck -- FreeSpin里不会掉落收集元素
    end

    local bReSpinFlag = rt:InReSpin()
    if bReSpinFlag then -- 仿真下任何时候都不会满足这个条件。。
        return deck
    end

    local nCollectID = SlotsGameLua:GetSymbolIdByObjName("CollectElem")

    local bFlag, nColossalNum = self:isNeedTriggerRespin()
    if bFlag then -- respin 和 bonusGame 都触发了 就把respin去掉。。
        local bTriggerBonusFlag = SweetBlastFunc:isTriggerBonusGame(deck)
        if bTriggerBonusFlag then
            bFlag = false
            nColossalNum = 0
        end
    end

    if not bFlag then
        -- 是否触发respin完全由程序控制 这种时候自由掉落触发的直接干掉

        local bTriggerReSpin = SweetBlastFunc:isTriggerRespin(deck)
        -- 是否触发respin完全由程序控制 这种时候自由掉落触发的直接干掉

        if bTriggerReSpin then
            for i = 0, 19 do -- 弃掉nCollectID
                if deck[i] == nCollectID then
                    deck[i] = math.random(1, 8) -- 随机取一些普通元素
                end
            end
        end

        return deck
    end

    -- 如果需要触发了 
    -- 1. 先把盘面上随机掉出来的干掉。。
    -- 触发respin了 把bonus也去掉。。bonus层级高于respin的黑幕了
    -- 2. 在盘面上布置大于等于6个收集元素 nColossalNum
    local nBonusID = SlotsGameLua:GetSymbolIdByObjName("Bonus")
    for i = 0, 19 do -- 弃掉nCollectID
        if deck[i] == nCollectID or deck[i] == nBonusID then
            deck[i] = math.random(1, 8) -- 随机取一些普通元素
        end
    end

    local listKeys = {}
    for i=1, 20 do
        table.insert(listKeys, i-1)
    end
    listKeys = self:shuffle(listKeys)
    for i=1, nColossalNum do
        local key = listKeys[i]
        deck[key] = nCollectID
    end

    SweetBlastLevelUI.m_bGingermanStoreRespinFlag = false -- baseGame 触发的respin

    return deck
end

function SweetBlastCustomDeck:shuffle(oldTable)
    local newTable = LuaThemeVideo2020Helper.shuffle(oldTable)
    return newTable
end

function SweetBlastCustomDeck:isNeedTriggerBonusGame()
    local rt = SlotsGameLua.m_GameResult
    if SweetBlastFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local bReSpinFlag = rt:InReSpin()
    local bFreeSpinFlag = rt:InFreeSpin()
    if bReSpinFlag or bFreeSpinFlag then
        return false, 0
    end

    local nProb = 0.01
    local returnType = ReturnRateManager.m_enumReturnRateType
    if returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
        nProb = 0.001
        
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate70 then
        nProb = 0.0028
        
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
        nProb = 0.006
        
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate140 then
        nProb = 0.007
        
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
        nProb = 0.018
        
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate1000 then
        nProb = 0.01
        
    end
    
    if self.m_bFreeSpinTest then
        nProb = 0.6
    end
    
    local listBonusNumProb = {100, 10, 2} -- 出3个 4个 5个 这3种情况的概率。。
    if math.random() < nProb then
        local index = LuaHelper.GetIndexByRate(listBonusNumProb)
        local nBonusNum = index + 2
        return true, nBonusNum
    end

    return false, 0
end

function SweetBlastCustomDeck:isNeedTriggerRespin()
    local nProb = 0.02

    local listColossalNumProb = {900, 50, 25, 5} -- 出6个 7个 8个 9个 这4种情况的概率。。

    local returnType = ReturnRateManager.m_enumReturnRateType
    if returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
        nProb = 0.0025
        listColossalNumProb = {900, 50, 25, 5}
        
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate70 then
        nProb = 0.0038
        listColossalNumProb = {900, 50, 25, 5}
        
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
        nProb = 0.006
        listColossalNumProb = {900, 50, 25, 5}
        
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate140 then
        nProb = 0.01
        listColossalNumProb = {900, 50, 25, 5}
        
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
        nProb = 0.023
        listColossalNumProb = {900, 50, 25, 5}
        
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate1000 then
        nProb = 0.02
        listColossalNumProb = {900, 50, 25, 5}
    end

    if self.m_bRespinTest then
        nProb = 0.9
    end
    
    if math.random() < nProb then
        SweetBlastLevelUI:addRespinTriggerNum() -- 统计触发了多少次respin ...

        local index = LuaHelper.GetIndexByRate(listColossalNumProb)
        local nColossalNum = index + 5
        return true, nColossalNum
    end

    return false, 0
end

function SweetBlastCustomDeck:checkRespinRules(deck)
    -- respin 里不要掉落bonus 以及 sticky元素的下方一定掉落一个collectelem
    
    local nCollectID = SlotsGameLua:GetSymbolIdByObjName("CollectElem")
    local nBonusID = SlotsGameLua:GetSymbolIdByObjName("Bonus")

    local nRowCount = SlotsGameLua.m_nRowCount
    for x=0, SlotsGameLua.m_nReelCount-1 do
        local reel = SlotsGameLua.m_listReelLua[x]
        for y=0, nRowCount-1 do
            local nkey = nRowCount * x + y
            local nID = deck[nkey]
            if nID == nBonusID then
                deck[nkey] = math.random(1, 8) -- 随便取个普通元素代替
            end

            local bres, nStickyIndex = reel:isStickyPos(y)
            if bres then
                deck[nkey] = nCollectID
            end

        end
    end

end

function SweetBlastCustomDeck:checkFreespinRules(deck)
    -- freespin 里不要掉落 bonus 以及  collectelem
    
    local nCollectID = SlotsGameLua:GetSymbolIdByObjName("CollectElem")
    local nBonusID = SlotsGameLua:GetSymbolIdByObjName("Bonus")

    for i=0, 19 do
        if deck[i] == nCollectID or deck[i] == nBonusID then
            deck[i] = math.random(1, 8)
        end
    end
    
end

function SweetBlastCustomDeck:checkBonusElemRules(deck)
    -- bonus 一列只能有一个
    local nBonusID = SlotsGameLua:GetSymbolIdByObjName("Bonus")
    local nRowCount = 4 --SlotsGameLua.m_nRowCount

    for x=0, 4 do
        local bFindBonus = false
        for y=0, 3 do
            local nkey = 4 * x + y
            local nID = deck[nkey]
            if nID == nBonusID then
                if bFindBonus then
                    deck[nkey] = math.random(1, 8) -- 随便取个普通元素代替
                else
                    bFindBonus = true
                end
            end
        end
    end

end

function SweetBlastCustomDeck:modifyCollectElemProb(deck)
    local rt = SlotsGameLua.m_GameResult
    if SweetBlastFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local bReSpinFlag = rt:InReSpin()
    if not bReSpinFlag then
        return
    end

    local bAddCollectElement, nAddCollectCount = self:checkReSpinAddCollectElem()

    if not bAddCollectElement then
        return
    end
    
    local normalElemKeys = {}
    for x=0, SlotsGameLua.m_nReelCount - 1 do
        local reel = SlotsGameLua.m_listReelLua[x]

        for y=0, SlotsGameLua.m_nRowCount - 1 do
            local nkey = SlotsGameLua.m_nRowCount * x + y
            local nSymbolID = deck[nkey]
            local type = SlotsGameLua:GetSymbol(nSymbolID).type
            local bres, nStickyIndex = reel:isStickyPos(y)
            if not bres then
                deck[nkey] = math.random(1, 8)
                table.insert(normalElemKeys, nkey)
            end
        end
    end

    nAddCollectCount = math.min(nAddCollectCount, #normalElemKeys)
    
    normalElemKeys = LuaThemeVideo2020Helper.shuffle(normalElemKeys)

    local nCollectID = SlotsGameLua:GetSymbolIdByObjName("CollectElem")

    for i=1, nAddCollectCount do
        local nKey = normalElemKeys[i]
        deck[nKey] = nCollectID
    end
end

-- ReSpin 增加收集的元素的概率
function SweetBlastCustomDeck:checkReSpinAddCollectElem(nSimSticknum, nCurSimReSpinCount)
    local rt = SlotsGameLua.m_GameResult
    if SweetBlastFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local fTriggerProb = 0.0
    local tableTriggerCountRate = {1, 1, 1}

    local listCollectValue = {12, 18}
    local listProb = {0.4, 0.3, 0.2}

    local listProb1 = {0.3, 0.2, 0.1} -- rt.m_nReSpinCount == 1
    local listProb2 = {0.4, 0.3, 0.2} -- == 2
    local listProb3 = {0.5, 0.4, 0.3} -- == 3

    local returnType = ReturnRateManager.m_enumReturnRateType
    if returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
        listCollectValue = {12, 15}
        
        listProb1 = {0.2, 0.1, 0.01}
        listProb2 = {0.5, 0.3, 0.01}
        listProb3 = {0.7, 0.5, 0.1}

        tableTriggerCountRate = {500, 5, 1}
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate70 then
        listCollectValue = {12, 15}

        listProb1 = {0.2, 0.1, 0.01}
        listProb2 = {0.6, 0.3, 0.01}
        listProb3 = {0.7, 0.5, 0.1}

        tableTriggerCountRate = {500, 5, 1}
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
        listCollectValue = {12, 16}

        listProb1 = {0.2, 0.2, 0.01}
        listProb2 = {0.6, 0.3, 0.1}
        listProb3 = {0.7, 0.5, 0.01}

        tableTriggerCountRate = {500, 5, 1}
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate140 then
        listCollectValue = {12, 16}

        listProb1 = {0.3, 0.2, 0.01}
        listProb2 = {0.6, 0.36, 0.06}
        listProb3 = {0.8, 0.5, 0.05}

        tableTriggerCountRate = {500, 5, 1}
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
        listCollectValue = {12, 16}

        listProb1 = {0.6, 0.3, 0.01}
        listProb2 = {0.8, 0.36, 0.1}
        listProb3 = {0.9, 0.5, 0.08}

        tableTriggerCountRate = {500, 5, 1}
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate1000 then
        listCollectValue = {13, 19}

        listProb1 = {0.6, 0.3, 0.01}
        listProb2 = {0.8, 0.6, 0.01}
        listProb3 = {0.9, 0.6, 0.2}
        
        tableTriggerCountRate = {500, 5, 1}
    end
    
    local nRespinCount = rt.m_nReSpinCount
    local nStickyNum = SweetBlastFunc:stickyElemNum() -- 返回已经固定的元素个数

    if SweetBlastFunc.m_bSimulationFlag then
        nStickyNum = nSimSticknum
        nRespinCount = nCurSimReSpinCount
    end

    if nRespinCount == 1 then
        listProb = listProb1
    elseif nRespinCount == 2 then
        listProb = listProb2
    elseif nRespinCount == 3 then
        listProb = listProb3
    end

    -- 当前盘面上已经固定几个了..
    if nStickyNum < listCollectValue[1] then
        fTriggerProb = listProb[1]
    elseif nStickyNum < listCollectValue[2] then
        fTriggerProb = listProb[2]
    else
        fTriggerProb = listProb[3]
    end

    return math.random() < fTriggerProb, LuaHelper.GetIndexByRate(tableTriggerCountRate)
end

------------------- 测试 -------------------------
function SweetBlastCustomDeck:InitTestData()
    self.m_nThemeTestType = 0

    if GameConfig.PLATFORM_EDITOR then
        if GameConfig.Instance.m_nThemeTestType > 0 then
            self.m_nThemeTestType = GameConfig.Instance.m_nThemeTestType

            if self.m_nThemeTestType > 0 then
                Debug.Log("关卡 测试数据 加载")
            else
                Debug.Log("关卡 正常数据 加载")
            end
        end
    end
    
    -- 测试位 1: FreeSpin 2: respin 4: 收集

    local bit1 = self.m_nThemeTestType & 1 -- freespin 测试 -- bonus
    local bit2 = self.m_nThemeTestType & (1<<1) -- respin 测试
    local bit3 = self.m_nThemeTestType & (1<<2) -- 收集 测试

    self.m_bFreeSpinTest = false
    self.m_bRespinTest = false
    self.m_bCollectTest = false

    if bit1 ~= 0 then
        self.m_bFreeSpinTest = true
    end
    if bit2 ~= 0 then
        self.m_bRespinTest = true
    end
    if bit3 ~= 0 then
        self.m_bCollectTest = true
    end
    
end     

SweetBlastCustomDeck:InitTestData()