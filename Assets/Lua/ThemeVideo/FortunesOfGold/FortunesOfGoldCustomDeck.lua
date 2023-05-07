
FortunesOfGoldCustomDeck = {}

FortunesOfGoldCustomDeck.m_EnumFreeSpinType = {SmallType1 = 1, SmallType2 = 2, SmallType3 = 3,
                                         MidType1 = 4, MidType2 = 5, MidType3 = 6,
                                         BigType1 = 7, BigType2 = 8, BigType3 = 9,}
                
function FortunesOfGoldCustomDeck:ModifyBigFreeSpinDeck(deck, nFreeSpinType)
    -- 3-145  4--185  5--260  -- 0.2
    --0.1 3--125 4--160  5--210

    local nProb = 0.1
    local cnt = 3
    if nFreeSpinType == 7 then -- 125
        cnt = 3
        nProb = 0.1
    elseif nFreeSpinType == 8 then -- 185
        cnt = 4
        nProb = 0.2
    elseif nFreeSpinType == 9 then -- 260
        cnt = 5
        nProb = 0.2
    end
    
    local nScatterID = SlotsGameLua:GetSymbolIdByObjName("Scatter")
    local nWildID = SlotsGameLua:GetSymbolIdByObjName("Wild")

    local nLineIDs = {}
    nLineIDs[1] = math.random(1, 10)
    nLineIDs[2] = math.random(11, 20)
    nLineIDs[3] = math.random(21, 30)
    for i=1, 3 do
        local ld = SlotsGameLua.m_listLineLua[ nLineIDs[i] ]
        local keys = {}
        keys[1] = SlotsGameLua.m_nRowCount * 0 + ld.Slots[0]
        keys[2] = SlotsGameLua.m_nRowCount * 1 + ld.Slots[1]
        keys[3] = SlotsGameLua.m_nRowCount * 2 + ld.Slots[2]
        keys[4] = SlotsGameLua.m_nRowCount * 3 + ld.Slots[3]
        keys[5] = SlotsGameLua.m_nRowCount * 4 + ld.Slots[4]
        
        for i=1, cnt do
            local key = keys[i]
            deck[key] = nScatterID
        end
    
        for i=0, 2 do
            local frandom = math.random()
            if frandom < nProb then
                FortunesOfGoldFunc.m_listReel2Deck2[i] = nScatterID
            end
        end
    end
end

function FortunesOfGoldCustomDeck:ModifyMidFreeSpinDeck(deck, nFreeSpinType)
    -- 3-82  4--102  5--135   -- 0.3
    --0.1 3--50  4--70  5--90

    local nProb = 0.1
    local cnt = 3
    if nFreeSpinType == 4 then -- 50
        cnt = 3
        nProb = 0.1
    elseif nFreeSpinType == 5 then -- 70
        cnt = 4
        nProb = 0.1
    elseif nFreeSpinType == 6 then -- 102
        cnt = 4
        nProb = 0.3
    end
    
    local nScatterID = SlotsGameLua:GetSymbolIdByObjName("Scatter")
    local nWildID = SlotsGameLua:GetSymbolIdByObjName("Wild")

    local nLineIDs = {}
    nLineIDs[1] = math.random(1, 15)
    nLineIDs[2] = math.random(16, 30)
    for i=1, 2 do
        local ld = SlotsGameLua.m_listLineLua[ nLineIDs[i] ]
        local keys = {}
        keys[1] = SlotsGameLua.m_nRowCount * 0 + ld.Slots[0]
        keys[2] = SlotsGameLua.m_nRowCount * 1 + ld.Slots[1]
        keys[3] = SlotsGameLua.m_nRowCount * 2 + ld.Slots[2]
        keys[4] = SlotsGameLua.m_nRowCount * 3 + ld.Slots[3]
        keys[5] = SlotsGameLua.m_nRowCount * 4 + ld.Slots[4]
        
        for i=1, cnt do
            local key = keys[i]
            deck[key] = nScatterID
        end
    
        for i=0, 2 do
            local frandom = math.random()
            if frandom < nProb then
                FortunesOfGoldFunc.m_listReel2Deck2[i] = nScatterID
            end
        end
    end
end

function FortunesOfGoldCustomDeck:ModifySmallFreeSpinDeck(deck, nFreeSpinType)
    local nProb = 0.3
    local cnt = 3
    if nFreeSpinType == 1 then -- 16
        cnt = 3
        nProb = 0.2
    elseif nFreeSpinType == 2 then -- 21
        cnt = 4
    elseif nFreeSpinType == 3 then -- 30
        cnt = 5
    end
    
    local nScatterID = SlotsGameLua:GetSymbolIdByObjName("Scatter")
    local nWildID = SlotsGameLua:GetSymbolIdByObjName("Wild")

    local nLineID = math.random(1, 30)
    local ld = SlotsGameLua.m_listLineLua[nLineID]
    local keys = {}
    keys[1] = SlotsGameLua.m_nRowCount * 0 + ld.Slots[0]
    keys[2] = SlotsGameLua.m_nRowCount * 1 + ld.Slots[1]
    keys[3] = SlotsGameLua.m_nRowCount * 2 + ld.Slots[2]
    keys[4] = SlotsGameLua.m_nRowCount * 3 + ld.Slots[3]
    keys[5] = SlotsGameLua.m_nRowCount * 4 + ld.Slots[4]
    
    for i=1, cnt do
        local key = keys[i]
        deck[key] = nScatterID
    end

    for i=0, 2 do
        local frandom = math.random()
        if frandom < nProb then
            FortunesOfGoldFunc.m_listReel2Deck2[i] = nScatterID
        end
    end
end

--1. 控制freespin、控制多把不中奖的情况等...
function FortunesOfGoldCustomDeck:ModifyCustomDeck(deck)
    local rt = SlotsGameLua.m_GameResult
    if FortunesOfGoldFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    if rt:InFreeSpin() then
        return
    end
    
    local fTriggerRate = 0
    local fTriggerSmalllFreeSpinRate = 0.9

    local nSmallFreeSpinUpperLimit = 50
    local nSmallFreeSpinLowerLimit = 8
    local nLargeFreeSpinUpperLimit = 900
    local nLargeFreeSpinLowerLimit = 50

    local returnType = ReturnRateManager.m_enumReturnRateType
    if returnType == enumReturnRateTYPE.enumReturnType_Rate50 then
        fTriggerRate = 0.001
        fTriggerSmalllFreeSpinRate = 0.9

        nSmallFreeSpinUpperLimit = 25
        nSmallFreeSpinLowerLimit = 8
        nLargeFreeSpinUpperLimit = 100
        nLargeFreeSpinLowerLimit = 25
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate95 then
        fTriggerRate = 0.005
        fTriggerSmalllFreeSpinRate = 0.9
        
        nSmallFreeSpinUpperLimit = 25
        nSmallFreeSpinLowerLimit = 8
        nLargeFreeSpinUpperLimit = 100
        nLargeFreeSpinLowerLimit = 30
    elseif returnType == enumReturnRateTYPE.enumReturnType_Rate200 then
        fTriggerRate = 0.015
        fTriggerSmalllFreeSpinRate = 0.9

        nSmallFreeSpinUpperLimit = 25
        nSmallFreeSpinLowerLimit = 8
        nLargeFreeSpinUpperLimit = 900
        nLargeFreeSpinLowerLimit = 50
    end

    local bTriggerFreeSpin = math.random() < fTriggerRate
    local bTriggerSmalllFreeSpin = math.random() < fTriggerSmalllFreeSpinRate
    if not bTriggerFreeSpin then
        return
    end

    local nCreateFreeSpinNum = 0
    if bTriggerSmalllFreeSpin then
        nCreateFreeSpinNum = math.random(nSmallFreeSpinLowerLimit, nSmallFreeSpinUpperLimit)
    else
        nCreateFreeSpinNum = math.random(nLargeFreeSpinLowerLimit, nLargeFreeSpinUpperLimit)
        if nCreateFreeSpinNum > 400 then
            if math.random() < 0.8 then
                nCreateFreeSpinNum = math.random(nLargeFreeSpinLowerLimit, nLargeFreeSpinUpperLimit / 2)
            end
        end
    end

    local bflag = self:CreateFreeSpinDeck(deck, nCreateFreeSpinNum)
    if bflag then
        local nScatterID = SlotsGameLua:GetSymbolIdByObjName("Scatter")
        local nWildID = SlotsGameLua:GetSymbolIdByObjName("Wild")

        for key = 3, 11 do
            local nSymbolID = deck[key]
            if nSymbolID == nScatterID then
                if math.random() < 0.35 then
                    deck[key] = nWildID
                end
            end
        end
    end
end

function FortunesOfGoldCustomDeck:CreateFreeSpinDeck(deck, nCreateFreeSpinNum)
  --  Debug.Log("-------------nCreateFreeSpinNum: " .. nCreateFreeSpinNum)

    if nCreateFreeSpinNum < 1 then
        return false
    end

    local nScatterID = SlotsGameLua:GetSymbolIdByObjName("Scatter")
    local nWildID = SlotsGameLua:GetSymbolIdByObjName("Wild")

    local nSymbolID = math.random(1, 10)
    for i=0, 14 do
        if deck[i] == nScatterID or deck[i] == nWildID then
            deck[i] = nSymbolID
        end
    end

    if nCreateFreeSpinNum < 20 then
        local nFreeSpinType = self.m_EnumFreeSpinType.SmallType1
        self:ModifySmallFreeSpinDeck(deck, nFreeSpinType)
        return true
    end

    if nCreateFreeSpinNum < 30 then
        local nFreeSpinType = self.m_EnumFreeSpinType.SmallType2
        self:ModifySmallFreeSpinDeck(deck, nFreeSpinType)
        return true
    end

    if nCreateFreeSpinNum < 50 then
        local nFreeSpinType = self.m_EnumFreeSpinType.SmallType3
        self:ModifySmallFreeSpinDeck(deck, nFreeSpinType)
        return true
    end

    if nCreateFreeSpinNum < 60 then
        local nFreeSpinType = self.m_EnumFreeSpinType.MidType1
        self:ModifyMidFreeSpinDeck(deck, nFreeSpinType)
        return true
    end

    if nCreateFreeSpinNum < 80 then
        local nFreeSpinType = self.m_EnumFreeSpinType.MidType2
        self:ModifyMidFreeSpinDeck(deck, nFreeSpinType)
        return true
    end

    if nCreateFreeSpinNum < 110 then
        local nFreeSpinType = self.m_EnumFreeSpinType.MidType3
        self:ModifyMidFreeSpinDeck(deck, nFreeSpinType)
        return true
    end
    
    if nCreateFreeSpinNum < 150 then
        local nFreeSpinType = self.m_EnumFreeSpinType.BigType1
        self:ModifyBigFreeSpinDeck(deck, nFreeSpinType)
        return true
    end
    
    if nCreateFreeSpinNum < 220 then
        local nFreeSpinType = self.m_EnumFreeSpinType.BigType2
        self:ModifyBigFreeSpinDeck(deck, nFreeSpinType)
    else
        local nFreeSpinType = self.m_EnumFreeSpinType.BigType3
        self:ModifyBigFreeSpinDeck(deck, nFreeSpinType)
    end

    return true
end