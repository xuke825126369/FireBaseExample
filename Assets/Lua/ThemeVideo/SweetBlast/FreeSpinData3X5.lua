FreeSpinData3X5 = {}

FreeSpinData3X5.m_LevelData = nil
FreeSpinData3X5.m_listSymbolLua = {} -- 赔率等
FreeSpinData3X5.m_listLineLua = {} -- 线


function FreeSpinData3X5:Init()
    self:readLevelData()
    self:InitParams()
end

function FreeSpinData3X5:readLevelData()
    -- local strleveldataJsonName = "FreeSpinData3X5.txt"
    -- local assetPath = strleveldataJsonName
    -- local objParam = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.TextAsset))
    -- local strParam = objParam.text
    -- self.m_LevelData = rapidjson.decode(strParam)

    self.m_LevelData = SlotsGameLua.m_LevelData
end

function FreeSpinData3X5:InitParams()
    local nRowCount = 3

    self.m_listSymbolLua = SlotsGameLua.m_listSymbolLua

    self:InitLineInfo()
    
end

-- 设置 中奖线信息
function FreeSpinData3X5:InitLineInfo()
    local nRowCount = 3
    local nReelCount = 5
    
    local tablePayLines = ThemePlayData:GetMatchPayLineTable(nReelCount, nRowCount)
    
    self.m_listLineLua = {}
    for k, v in pairs(tablePayLines) do
        local color = Unity.Color.green
        local lineLua = LineLua:create(nReelCount, color)
        for index = 0, 4 do
            lineLua.Slots[index] = v.winLine[index + 1]
        end

        self.m_listLineLua[k] = lineLua
    end

end

function FreeSpinData3X5:GetSymbol(nSymbolID) --//从1开始
    if nSymbolID == nil then
        Debug.Log("---------FreeSpinData3X5:GetSymbol(nSymbolID)----nSymbolID == nil-----")
    end

    local symbollua = self.m_listSymbolLua[nSymbolID]
    if symbollua == nil then
        Debug.Log("---FreeSpinData3X5--symbollua == nil------nSymbolID: ".. nSymbolID)
    end
   
    return symbollua
end

-- 分2棋盘 3棋盘 4棋盘
-- freespin 下的多棋盘们的getdeck方法..
function FreeSpinData3X5:get2XDeck()
    local listRandomDeck = self:init2XDeckParam()

    local deck = {} -- 索引从0开始

    for nReelIndex=1, 5 do
        local reelDeck = listRandomDeck[nReelIndex]
        local nRandomIndex = math.random(1, #reelDeck-2)
        local nkey = 3 * (nReelIndex - 1)
        for i=0, 2 do
            local nID = reelDeck[nRandomIndex + i]
            deck[nkey + i] = nID
        end
    end

    self:ModifyDeckStickyWild(deck)

    return deck
end

function FreeSpinData3X5:get3XDeck()
    local listRandomDeck = self:init3XDeckParam()

    local deck = {} -- 索引从0开始

    for nReelIndex=1, 5 do
        local reelDeck = listRandomDeck[nReelIndex]
        local nRandomIndex = math.random(1, #reelDeck-2)
        local nkey = 3 * (nReelIndex - 1)
        for i=0, 2 do
            local nID = reelDeck[nRandomIndex + i]
            deck[nkey + i] = nID
        end
    end

    self:ModifyDeckStickyWild(deck)

    return deck
end

function FreeSpinData3X5:get4XDeck()
    local listRandomDeck = self:init4XDeckParam()

    local deck = {} -- 索引从0开始

    for nReelIndex=1, 5 do
        local reelDeck = listRandomDeck[nReelIndex]
        local nRandomIndex = math.random(1, #reelDeck-2)
        local nkey = 3 * (nReelIndex - 1)
        for i=0, 2 do
            local nID = reelDeck[nRandomIndex + i]
            deck[nkey + i] = nID
        end
    end

    self:ModifyDeckStickyWild(deck)

    return deck
end

-- 固定了wild的列在deck表里对应位置上填上wild1X1
function FreeSpinData3X5:ModifyDeckStickyWild(deck)
    local nWildID = 11 -- 1X1 的wild

    -- 如果有超过2列都固定成wild了 就取消掉盘面上的所有小wild..
    local listWildReelIDs = SweetBlastFreeSpinCommon.m_listWildReelIDs
    if #listWildReelIDs >= 2 then
        for key=0, 14 do
            if deck[key] == nWildID then
                deck[key] = math.random(1, 6)
            elseif (deck[key] > 7) and (key < 10) and (math.random() < 0.8) then
                deck[key] = math.random(1, 7)
            end
        end
    end

    -- 如果没有固定wild列 就增加掉盘面上的小wild..
    if #listWildReelIDs == 0 then
        for key=0, 14 do
            if deck[key] ~= nWildID then
                if math.random() < 0.2 then
                    deck[key] = nWildID
                end
            end
        end
    end

    -- 固定wild背后的小元素都改为wild
    local listWildReelIDs = SweetBlastFreeSpinCommon.m_listWildReelIDs
    for i=1, #listWildReelIDs do
        local nReelID = listWildReelIDs[i]
        for y=0, 2 do
            local key = 3 * nReelID + y
            deck[key] = nWildID
        end
    end
end

-- 1 2 3 4 5 6 7 8 低级元素
-- 9 10 高级元素
-- 11 wild
-- 15 3X1的大wild

function FreeSpinData3X5:init2XDeckParam()
    local reel1Deck = {
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
        4, 5, 6, 7, 8, 9, 10, 6, 7, 8, 9, 10, 11, 
        7, 8, 9, 10, 11, 6, 5, 4, 3, 7, 8, 9, 10
    }
    local reel2Deck = {
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
        4, 5, 6, 7, 8, 9, 10, 6, 7, 8, 9, 10, 11, 
        7, 8, 9, 10, 11, 6, 5, 4, 3, 7, 8, 9, 10
    }
    local reel3Deck = {
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
        4, 5, 6, 7, 8, 9, 10, 6, 7, 8, 9, 10, 11, 
        7, 8, 9, 10, 11, 6, 5, 4, 3, 7, 8, 9, 10
    }
    local reel4Deck = {
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
        4, 5, 6, 7, 8, 9, 10, 6, 7, 8, 9, 10, 11, 
        7, 8, 9, 10, 11, 6, 5, 4, 3, 7, 8, 9, 10
    }
    local reel5Deck = {
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 10,
        4, 5, 6, 7, 8, 9, 10, 6, 7, 8, 9, 10, 11, 
        7, 8, 9, 10, 11, 6, 5, 4, 3, 7, 8, 9, 10
    }
    
    local listDeck = {}
    listDeck[1] = reel1Deck
    listDeck[2] = reel2Deck
    listDeck[3] = reel3Deck
    listDeck[4] = reel4Deck
    listDeck[5] = reel5Deck
    return listDeck
end

function FreeSpinData3X5:init3XDeckParam()
    local reel1Deck = {
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11,
        4, 5, 6, 7, 8, 9, 10, 6, 7, 8, 9, 10, 8, 
        7, 8, 9, 10, 8, 6, 5, 4, 9, 7, 8, 9, 10
    }
    local reel2Deck = {
        7, 8, 9, 10, 5, 6, 7, 8, 9, 10, 11,
        4, 5, 6, 7, 8, 9, 10, 6, 7, 8, 9, 10, 9, 
        7, 8, 9, 10, 9, 6, 5, 4, 8, 7, 8, 9, 10
    }
    local reel3Deck = {
        7, 8, 9, 10, 5, 6, 7, 8, 9, 10, 11,
        4, 5, 6, 7, 8, 9, 10, 6, 7, 8, 9, 10, 11, 
        7, 8, 9, 10, 10, 6, 5, 4, 7, 7, 8, 9, 10
    }
    local reel4Deck = {
        7, 8, 9, 10, 5, 6, 7, 8, 9, 10, 10,
        4, 5, 6, 7, 8, 9, 10, 6, 7, 8, 9, 10, 11, 
        7, 8, 9, 10, 11, 6, 5, 4, 6, 7, 8, 9, 10
    }
    local reel5Deck = {
        7, 8, 9, 10, 5, 6, 7, 8, 9, 10, 10,
        4, 5, 6, 7, 8, 9, 10, 6, 7, 8, 9, 10, 10, 
        7, 8, 9, 10, 10, 6, 5, 4, 3, 7, 8, 9, 10
    }

    local listDeck = {}
    listDeck[1] = reel1Deck
    listDeck[2] = reel2Deck
    listDeck[3] = reel3Deck
    listDeck[4] = reel4Deck
    listDeck[5] = reel5Deck
    return listDeck
end

function FreeSpinData3X5:init4XDeckParam()
    local reel1Deck = {
        1, 2, 3, 4, 5, 6, 1, 7, 8, 5, 6, 1, 2, 3, 9, 1, 2, 8, 3, 4, 5, 9, 1,
        2, 5, 6, 10, 1, 2, 3, 4, 5, 8, 1, 2, 3, 4, 5, 1, 2, 3, 4, 5, 6, 7,
        4, 5, 6, 9, 1, 2, 3, 4, 5, 8, 1, 2, 3, 4, 5, 9, 6, 8, 1, 2, 3
    }
    local reel2Deck = {
        1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 2, 3, 4, 5, 6, 10, 1, 2, 3, 4, 5, 6, 11,
        1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 9, 10, 1, 2, 3, 4, 5, 6, 1, 
        4, 5, 6, 7, 1, 2, 3, 6, 7, 1, 1, 3, 6, 4, 5, 1, 2, 3, 4, 5, 6, 1, 2, 3, 
        7, 1, 2, 3, 9, 6, 5, 4, 1, 7, 1, 2, 3, 1, 2, 3, 4, 5, 1, 2, 3, 4
    }
    local reel3Deck = {
        1, 2, 3, 4, 5, 6, 7, 8, 9, 1, 11, 2, 3, 1, 5, 7, 2, 3, 4, 5, 6, 1, 2, 3, 4, 5, 6,
        4, 5, 6, 7, 8, 9, 2, 3, 4, 5, 6, 10, 2, 3, 4, 5, 6, 6, 7, 8, 9, 10, 6, 1, 2, 3, 4,
        7, 8, 9, 2, 3, 4, 5, 6, 10, 2, 3, 4, 5, 6, 11, 6, 5, 4, 9, 7, 9, 2, 3, 4, 5, 6, 10
    }
    local reel4Deck = {
        1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 7, 1, 2, 3, 4, 10, 1, 2, 3, 4, 5, 6, 7, 11, 1, 2,
        4, 5, 6, 7, 8, 2, 3, 4, 5, 6, 9, 2, 3, 4, 5, 6, 10, 6, 7, 8, 9, 2, 3, 4, 5, 6, 11, 
        1, 2, 3, 10, 2, 3, 4, 5, 6, 11, 2, 3, 4, 5, 6, 6, 5, 4, 7, 1, 8, 2, 10
    }
    local reel5Deck = {
        1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 9, 3, 4, 5, 1, 10, 2, 3, 4, 5, 1, 10,
        4, 5, 6, 7, 1, 2, 3, 6, 1, 8, 2, 3, 4, 1, 2, 3, 4, 5, 6, 7, 3, 1, 2,
        1, 2, 3, 4, 5, 1, 5, 4, 3, 7, 5, 2, 3, 6, 1, 4, 5, 8, 11
    }

    local listDeck = {}
    listDeck[1] = reel1Deck
    listDeck[2] = reel2Deck
    listDeck[3] = reel3Deck
    listDeck[4] = reel4Deck
    listDeck[5] = reel5Deck
    return listDeck
end

-- 中奖结算

function FreeSpinData3X5:GetLine(index)---从1开始
    return self.m_listLineLua[index]
end

function FreeSpinData3X5:isSamekindSymbol(SymbolIdx, nResultId)
    local bWildFlag1 = self:GetSymbol(SymbolIdx):IsWild()
    local bWildFlag2 = self:GetSymbol(nResultId):IsWild()

    if bWildFlag1 or bWildFlag2 then
        return true
    end

    if SymbolIdx == nResultId then
        return true
    end

    return false
end

function FreeSpinData3X5:CheckSpinWinPayLines(deck, result, game)
    result:ResetSpin()

    local nWildID = 11 -- wild

    for i = 1, #self.m_listLineLua do
        local iResult = {}
        local ld = self:GetLine(i)
        for x=0, 4 do
            local y = ld.Slots[x]
            iResult[x] = deck[3 * x + y]
        end

        local nMaxMatchReelID = 0
        local MatchCount = 0
        local bFirstSymbol = false
        local SymbolIdx = -1
        for x=0, 4 do
            local bNormalFlag = self:GetSymbol(iResult[x]):IsNormalSymbol()
            if not bFirstSymbol then
                if not SweetBlastFunc:IsWild(iResult[x]) then
                    if (not bNormalFlag) and (MatchCount > 0) then -- 这是遇到scatter牌了
                        break
                    end
                    SymbolIdx = iResult[x]
                    bFirstSymbol = true
                end

                MatchCount = MatchCount + 1
                nMaxMatchReelID = x
            else
                local curSymbol = self:GetSymbol(SymbolIdx)
                bNormalFlag = curSymbol:IsNormalSymbol()

                local bSameKindSymbolFlag = false
                bSameKindSymbolFlag = self:isSamekindSymbol(SymbolIdx, iResult[x])
                if bSameKindSymbolFlag or (SweetBlastFunc:IsWild(iResult[x]) and bNormalFlag) then
                    MatchCount = MatchCount + 1

                    nMaxMatchReelID = x
                else
                    break
                end
            end
        end
        if MatchCount >= 1 then
            local bcond1 = false
            local bcond2 = false
            local bcond3 = false

            local nCombIndex = -1
            local sd = nil
            local fCombReward = 0.0
            if SymbolIdx == -1 then
                sd = self:GetSymbol(nWildID)
                fCombReward = sd.m_freeSpinRewards[MatchCount]
                bcond1 = true
                SymbolIdx = nWildID
            else
                sd = self:GetSymbol(SymbolIdx)
                if sd.type == SymbolType.Normal or sd.type == SymbolType.NormalDouble or sd.type > 100 then
                    fCombReward = sd.m_freeSpinRewards[MatchCount]
                    bcond3 = true
                end
            end

            if fCombReward > 0 then
                self.m_nWin0Count = 0

                if not SweetBlastFunc.m_bSimulationFlag then
                    -- 哪根线的哪几个元素中奖了 记录下来
                    --m_listHitSymbols
                    self:refreshHitSymbols(i, MatchCount, game)
                end
                --

                local fLineBet = SceneSlotGame.m_nTotalBet / 100 -- #self.m_listLineLua
                local LineWin = fCombReward * fLineBet

             --   Debug.Log("--------fCombReward: " .. fCombReward .. "   ---name: " .. sd.prfab.name)

                if not SweetBlastFunc.m_bSimulationFlag then
                    table.insert(result.m_listWins,
                                WinItem:create(i, SymbolIdx, MatchCount, LineWin, bcond2, nMaxMatchReelID) )
                end

                result.m_fSpinWin = result.m_fSpinWin + LineWin

                if SweetBlastFunc.m_bSimulationFlag then
                    if result.m_listTestWinSymbols[SymbolIdx] == nil then
                        result.m_listTestWinSymbols[SymbolIdx] = TestWinItem:create(SymbolIdx)
                    end

                    -- result.m_listTestWinSymbols[SymbolIdx].Hit = result.m_listTestWinSymbols[SymbolIdx].Hit + 1
                    -- result.m_listTestWinSymbols[SymbolIdx].WinGold =
                    --     result.m_listTestWinSymbols[SymbolIdx].WinGold + LineWin
                end
            else
            end
        end
    end

    result.m_fGameWin = result.m_fGameWin + result.m_fNonLineBonusWin
    result.m_fGameWin = result.m_fGameWin + result.m_fSpinWin

    if result:InFreeSpin() then
        result.m_fFreeSpinTotalWins = result.m_fFreeSpinTotalWins + result.m_fSpinWin
        result.m_fFreeSpinAccumWins = result.m_fFreeSpinAccumWins + result.m_fSpinWin

        result.m_fFreeSpinTotalWins = result.m_fFreeSpinTotalWins + result.m_fNonLineBonusWin
        result.m_fFreeSpinAccumWins = result.m_fFreeSpinAccumWins + result.m_fNonLineBonusWin

        result.m_fFreeSpinTotalWins = result.m_fFreeSpinTotalWins + result.m_fJackPotBonusWin
        result.m_fFreeSpinAccumWins = result.m_fFreeSpinAccumWins + result.m_fJackPotBonusWin
    end

    return result
end

-- 哪根线的哪几个元素中奖了 记录下来
-- m_listHitSymbols
function FreeSpinData3X5:refreshHitSymbols(nLineId, MatchCount, game)
    local nMaxMatchId = MatchCount - 1
    local nRowCount = 3
    for x = 0, 4 do -- 3X5 棋盘
        if x <= nMaxMatchId then
            local y = self:GetLine(nLineId).Slots[x]
            local nkey = nRowCount * x + y

            local bflag = LuaHelper.tableContainsElement(game.m_listHitSymbols, nkey)
            if not bflag then
                table.insert(game.m_listHitSymbols, nkey)
            end
        end
    end
end

----- 仿真专用。。
function FreeSpinData3X5:getFreeSpinSimuResult(nFreeSpinNum, nFreeSpinType, listWildReelID)
    -- 多个棋盘 一次freespin 赢得的金币数
    local nSlotsGameNum = 0
    local deckFunc = nil
    if nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin3X5_2 then
        nSlotsGameNum = 2
        deckFunc = self.get2XDeck
    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin3X5_3 then
        nSlotsGameNum = 3
        deckFunc = self.get3XDeck
    elseif nFreeSpinType == EnumSweetBlastFreeSpinType.FreeSpin3X5_4 then
        nSlotsGameNum = 4
        deckFunc = self.get4XDeck
    end

    SweetBlastFreeSpinCommon.m_listWildReelIDs = listWildReelID

    local fTotalWin = 0
    for i=1, nFreeSpinNum do
        for i=1, nSlotsGameNum do
            local deck = deckFunc(self)
            self:CheckSpinWinPayLines(deck, SlotsGameLua.m_TestGameResult, nil)
            local fWin = SlotsGameLua.m_TestGameResult.m_fSpinWin
            fTotalWin = fTotalWin + fWin
        end
    end

 --   Debug.Log("-------nFreeSpinNum-------: " .. nFreeSpinNum)
 --   Debug.Log("----simu---nFreeSpinType: " .. nFreeSpinType .. ",  fTotalWin: " .. fTotalWin)
    
    return fTotalWin
end