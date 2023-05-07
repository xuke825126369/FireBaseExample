SweetBlastSimulation = {}

SweetBlastSimulation.m_nSimulationCount = 0 -- 仿真统计专用

SweetBlastSimulation.m_fGingermanStoreWinCoins = 0
SweetBlastSimulation.m_fGingermanTotalNum = 0
SweetBlastSimulation.m_fGingermanUnUsedNum = 0 -- 最后兑换完剩余的...

SweetBlastSimulation.m_nBaseGameTriggerRespinNum = 0
SweetBlastSimulation.m_fBaseRespinTotalWin = 0
SweetBlastSimulation.m_nBaseGameTriggerBonusGameNum = 0
SweetBlastSimulation.m_fBaseBonusGameTotalWin = 0

SweetBlastSimulation.m_fBaseTotalWin = 0

-- 所有Bonus...
SweetBlastSimulation.m_fBonusGameTotalWin = 0 -- 在多类获得的时候累加 用于验证是否等于下面2个之和
SweetBlastSimulation.m_fBonusGameGridWin = 0 -- Bonusgame里踩格子赚的
SweetBlastSimulation.m_fBonusGameFreeSpinWin = 0 -- Bonusgame里最后freespin赚的
--
-- 所有Gingerman store...
SweetBlastSimulation.m_fGingermanStoreTotalWin = 0
SweetBlastSimulation.m_fGingermanStoreBoxWin = 0 -- 开箱子赚的
SweetBlastSimulation.m_fGingermanStoreBonusGameWin = 0 -- 开箱子出的Bonusgame里赚的
SweetBlastSimulation.m_fGingermanStoreRespinWin = 0 -- 开箱子出的Respin里赚的
SweetBlastSimulation.m_fGingermanStoreFullFreeSpinWin = 0 -- 收满一页奖励的freespin赚的
--

SweetBlastSimulation.m_fAllFreeSpinWinCoins = 0 -- 这部分在 rt.m_fGameWin 里加了两次...

SweetBlastSimulation.m_nBonusTotalWinGingermanNum = 0 -- bonusgame里一共赚了多少gingerman

SweetBlastSimulation.m_nBonusGameTotalFreeSpinNum = 0 -- 所有bonusgame里获得多少次freespin
SweetBlastSimulation.m_nBonusGameTotalCount = 0

SweetBlastSimulation.m_nTotalRespinCount = 0 -- 总的respin次数
SweetBlastSimulation.m_nTotalRespinCollectNum = 0 -- 总的收集数。。

--仿真，把结果 输入到文本文件中
function SweetBlastSimulation:GetTestResultByRate()

    self.m_fGingermanStoreWinCoins = 0
    self.m_fGingermanTotalNum = 0
    self.m_fGingermanUnUsedNum = 0 -- 最后兑换完剩余的...

    self.m_nBaseGameTriggerRespinNum = 0
    self.m_fBaseRespinTotalWin = 0
    self.m_nBaseGameTriggerBonusGameNum = 0
    self.m_fBaseBonusGameTotalWin = 0
    self.m_fBaseTotalWin = 0

    self.m_fBonusGameTotalWin = 0
    self.m_fBonusGameGridWin = 0 -- Bonusgame里踩格子赚的
    self.m_fBonusGameFreeSpinWin = 0 -- Bonusgame里最后freespin赚的

    self.m_fGingermanStoreTotalWin = 0
    self.m_fGingermanStoreBoxWin = 0 -- 开箱子赚的
    self.m_fGingermanStoreBonusGameWin = 0 -- 开箱子出的Bonusgame里赚的
    self.m_fGingermanStoreRespinWin = 0 -- 开箱子出的Respin里赚的
    self.m_fGingermanStoreFullFreeSpinWin = 0 -- 

    self.m_fAllFreeSpinWinCoins = 0
    self.m_nBonusTotalWinGingermanNum = 0

    self.m_nBonusGameTotalFreeSpinNum = 0 -- 所有bonusgame里获得多少次freespin
    self.m_nBonusGameTotalCount = 0
    
    self.m_nTotalRespinCount = 0 -- 总的respin次数
    self.m_nTotalRespinCollectNum = 0 -- 总的收集数。。

    local rt = SlotsGameLua.m_TestGameResult
    rt:ResetGame(true)

    local preEnumReaturnRateType = ReturnRateManager.m_enumReturnRateType
    
    local nPreTotalBet = SceneSlotGame.m_nTotalBet
    SceneSlotGame.m_nTotalBet = 1
    


    ReturnRateManager.m_enumReturnRateType = SlotsGameLua.m_enumSimRateType
    ChoiceCommonFunc:CreateChoice()



    local nSimulationCount = SlotsGameLua.m_SimulationCount

    local nWin0Count = 0
    self.m_nSimulationWin0SpinNum = 0 -- 统计仿真期间一共有多少次没有中奖

    SweetBlastLevelParam.m_listJackpotValue = {0, 0, 0, 0} -- 仿真下 清零了。。也不恢复了

    local param = SweetBlastLevelParam.m_CollectInfo
    param.m_nCollectNum = 0

    local c = 0
    while true do
        local bReSpinFlag = rt:InReSpin()
        local bFreeSpinFlag = rt:InFreeSpin()
        
        if SlotsGameLua.m_enumSimRateType == enumReturnRateTYPE.enumReturnType_Null then
            local fTotalUse = 1.0 * (c  - rt.m_nFreeSpinAccumCount)
            local fTotalWin = rt.m_fGameWin
            local fWinMoneyCount = fTotalWin - fTotalUse
            local fRemainMoneyCount = SlotsGameLua.m_nSimulationMaxCoins + fWinMoneyCount

            table.insert(SlotsGameLua.m_nSimuTableRemainMoneyPerSpin, fRemainMoneyCount)
            
            if fRemainMoneyCount <= 0.1 or c >= SlotsGameLua.m_nSimulationMaxCoins * 40 * 10 then
                Debug.Log("仿真次数： "..c.."剩余钱数： "..fRemainMoneyCount)
                break
            else
                if c % 100 == 0 then
                    SimuReturnRateUtil.m_nLevel = SimuReturnRateUtil.m_nLevel + 1
                end

                ReturnRateManager.m_enumReturnRateType = SimuReturnRateUtil:getSimuReturnRateType()
                ChoiceCommonFunc:CreateChoice()
            end
        else
            if c >= 2 * nSimulationCount then
                break
            end

            if c >= nSimulationCount and (not bFreeSpinFlag) and (not bReSpinFlag) then
                break
            end 
        end 
            
        local bFlag = rt:Spin()
        if bFlag then
            -- freeSpin 结束了 把固定的wild取消掉
            
        end

        if rt.m_nFreeSpinTotalCount > 0 then
            rt.m_nFreeSpinCount = rt.m_nFreeSpinCount + 1
        end
        
        if not bFreeSpinFlag then
            SweetBlastLevelUI:addJackPotValue(true)
        end

        local iDeck = SweetBlastFunc:GetDeck()
        
        local fWin = self:getSpinWinSimu(iDeck, rt) -- 触发了bonusgame respin等的情况也一次处理了

        -- rt = SweetBlastFunc:CheckSpinWinPayLines(iDeck, rt)

        local nMaxCount = 10
        if fWin <= 0.0 then -- rt.m_fSpinWin
            nWin0Count = nWin0Count + 1
            self.m_nSimulationWin0SpinNum = self.m_nSimulationWin0SpinNum + 1
        elseif nWin0Count > 0 then
            if nWin0Count > nMaxCount then
                if rt.m_TestWin0Nums[nMaxCount] == nil then
                    rt.m_TestWin0Nums[nMaxCount] = 1
                else
                    rt.m_TestWin0Nums[nMaxCount] = rt.m_TestWin0Nums[nMaxCount] + 1
                end
            else
                for i=1, nWin0Count do
                    if rt.m_TestWin0Nums[i] == nil then
                        rt.m_TestWin0Nums[i] = 1
                    else
                        rt.m_TestWin0Nums[i] = rt.m_TestWin0Nums[i] + 1
                    end
                end
            end
            nWin0Count = 0
        else
            --
        end

        if not bReSpinFlag then
            c = c + 1
        end
    end

    local param = SweetBlastLevelParam.m_CollectInfo
    self.m_fGingermanTotalNum = param.m_nCollectNum
    local fWin = self:GingermanStoreSimulation()
    self.m_fGingermanStoreWinCoins = fWin
    self.m_fGingermanUnUsedNum = param.m_nCollectNum
    
    rt.m_fGameWin = rt.m_fGameWin + fWin
    rt.m_fGameWin = rt.m_fGameWin - self.m_fAllFreeSpinWinCoins
    
    self.m_nSimulationCount = c
    SlotsGameLua.m_TestGameResult = rt
    SceneSlotGame.m_nTotalBet = nPreTotalBet  --下注 金额 还原
    ReturnRateManager.m_enumReturnRateType = preEnumReaturnRateType
    ChoiceCommonFunc:CreateChoice()

    SweetBlastLevelParam:setBonusGameInfoEmpty()
end

function SweetBlastSimulation:WriteToFile()
    local strFile = ThemeLoader.themeKey .. "\n"
    local levelReturnRateType = SlotsGameLua.m_enumSimRateType
    if levelReturnRateType == enumReturnRateTYPE.enumReturnType_Rate200 then
        strFile = strFile.."=============enumReturnType_Rate200============\n"
    elseif levelReturnRateType == enumReturnRateTYPE.enumReturnType_Rate140 then
        strFile = strFile.."===========enumReturnType_Rate140==============\n"
    elseif levelReturnRateType == enumReturnRateTYPE.enumReturnType_Rate95 then
        strFile = strFile.."============enumReturnType_Rate95===============\n"
    elseif levelReturnRateType == enumReturnRateTYPE.enumReturnType_Rate50 then
        strFile = strFile.."==========enumReturnType_Rate50=============\n"
    elseif levelReturnRateType == enumReturnRateTYPE.enumReturnType_Rate70 then
        strFile = strFile.."=======enumReturnType_Rate70======\n"
    elseif levelReturnRateType == enumReturnRateTYPE.enumReturnType_Null then
        strFile = strFile.."=========enumReturnType_Null==========\n"
    end

    local rt = SlotsGameLua.m_TestGameResult
    local fTotalUse = 1.0 * (self.m_nSimulationCount  - rt.m_nFreeSpinAccumCount)
    local fTotalWin = rt.m_fGameWin
    local Ratio = fTotalWin / fTotalUse

    strFile = strFile.."Test SimulationCount:  "..SlotsGameLua.m_SimulationCount.."\n"
    strFile = strFile.."Actual SimulationCount:  "..self.m_nSimulationCount.."\n"
    strFile = strFile.."TotalBets : "..fTotalUse.."\n"
    strFile = strFile.."TotalWins : "..fTotalWin.."\n"
    strFile = strFile.."Return Rate: "..Ratio.."\n"
    strFile = strFile .. "----------------------------------" .. "\n"

    local nSymbolCount = #SlotsGameLua.m_listSymbolLua
    for i=1, nSymbolCount + 1 do
        local name = ""
        if i <= nSymbolCount then
            name = SlotsGameLua.m_listSymbolLua[i].prfab.name
        end

        local nHit = 0
        local fWinGold = 0
        if rt.m_listTestWinSymbols[i] ~= nil then
            nHit = rt.m_listTestWinSymbols[i].Hit
            fWinGold = rt.m_listTestWinSymbols[i].WinGold
        end
        strFile = strFile.."Name: "..name .." | HitWinCount: "..nHit.." | WinGolds: "..fWinGold.."\n"
    end

    strFile = strFile.. "\n"

    local nMaxCount = 10
    for i=1, nMaxCount do
        if rt.m_TestWin0Nums[i] > 0 then
            local strTemp = "Win0Count_" .. tostring(i) .. ": "
            strFile = strFile.. strTemp .. rt.m_TestWin0Nums[i] .. "\n"
        end
    end

    local fWin0Rate = self.m_nSimulationWin0SpinNum / self.m_nSimulationCount
    strFile = strFile.."fWin0Rate: " .. fWin0Rate .. "\n"

    strFile = strFile.. "\n"

    strFile = strFile.."FreeSpin TotalNum: " .. rt.m_nFreeSpinAccumCount .. "\n"
    strFile = strFile.."FreeSpin TotalWin: " .. rt.m_fFreeSpinAccumWins .. "\n"
    strFile = strFile.. "\n"
    

    strFile = strFile.."m_nBaseGameTriggerRespinNum: " .. self.m_nBaseGameTriggerRespinNum .. "\n"
    strFile = strFile.."m_fBaseRespinTotalWin: " .. self.m_fBaseRespinTotalWin .. "\n"
    local fAvgRespinWin = self.m_fBaseRespinTotalWin / self.m_nBaseGameTriggerRespinNum
    strFile = strFile.."fAvgRespinWin: " .. fAvgRespinWin .. "\n"

    strFile = strFile.."m_nTotalRespinCount: " .. self.m_nTotalRespinCount .. "\n"
    strFile = strFile.."m_nTotalRespinCollectNum: " .. self.m_nTotalRespinCollectNum .. "\n"
    local fAvgRespinCollectNum = self.m_nTotalRespinCollectNum / self.m_nTotalRespinCount
    strFile = strFile.."fAvgRespinCollectNum: " .. fAvgRespinCollectNum .. "\n"

    strFile = strFile.. "\n"

    strFile = strFile.."m_nBaseGameTriggerBonusGameNum: " .. self.m_nBaseGameTriggerBonusGameNum .. "\n"
    strFile = strFile.."m_fBaseBonusGameTotalWin: " .. self.m_fBaseBonusGameTotalWin .. "\n"
    strFile = strFile.. "\n"

    strFile = strFile.."m_fGingermanStoreWinCoins: " .. self.m_fGingermanStoreWinCoins .. "\n"
    strFile = strFile.."m_fGingermanTotalNum: " .. self.m_fGingermanTotalNum .. "\n"
    strFile = strFile.."m_nBonusTotalWinGingermanNum: " .. self.m_nBonusTotalWinGingermanNum .. "\n"
    strFile = strFile.."m_fGingermanUnUsedNum: " .. self.m_fGingermanUnUsedNum .. "\n"
    strFile = strFile.. "\n"

    strFile = strFile.."m_fBaseTotalWin: " .. self.m_fBaseTotalWin .. "\n"
    strFile = strFile.. "\n"

    strFile = strFile.. "-------------BonusGame------------------" .. "\n"
    strFile = strFile.."m_nBonusGameTotalCount: " .. self.m_nBonusGameTotalCount .. "\n"
    strFile = strFile.."m_nBonusGameTotalFreeSpinNum: " .. self.m_nBonusGameTotalFreeSpinNum .. "\n"
    local fAvgFreeSpinNum = self.m_nBonusGameTotalFreeSpinNum / self.m_nBonusGameTotalCount
    strFile = strFile.."fAvgFreeSpinNum: " .. fAvgFreeSpinNum .. "\n"
    strFile = strFile.. "\n"

    strFile = strFile.."m_fBonusGameTotalWin: " .. self.m_fBonusGameTotalWin .. "\n"
    strFile = strFile.."m_fBonusGameGridWin: " .. self.m_fBonusGameGridWin .. "\n"
    strFile = strFile.."m_fBonusGameFreeSpinWin: " .. self.m_fBonusGameFreeSpinWin .. "\n"
    local fAvgFreeSpinWin = self.m_fBonusGameFreeSpinWin / self.m_nBonusGameTotalCount
    strFile = strFile.."fAvgFreeSpinWin: " .. fAvgFreeSpinWin .. "\n"

    strFile = strFile.. "\n"

    strFile = strFile.. "-------------GingermanStore------------------" .. "\n"
    strFile = strFile.."m_fGingermanStoreTotalWin: " .. self.m_fGingermanStoreTotalWin .. "\n"
    strFile = strFile.."m_fGingermanStoreBoxWin: " .. self.m_fGingermanStoreBoxWin .. "\n"
    strFile = strFile.."m_fGingermanStoreBonusGameWin: " .. self.m_fGingermanStoreBonusGameWin .. "\n"
    strFile = strFile.."m_fGingermanStoreRespinWin: " .. self.m_fGingermanStoreRespinWin .. "\n"
    strFile = strFile.."m_fGingermanStoreFullFreeSpinWin: " .. self.m_fGingermanStoreFullFreeSpinWin .. "\n"
    
    strFile = strFile.."m_nFullPages: " .. self.m_nFullPages .. "\n"

    strFile = strFile.. "\n"
    
    local dir =  Unity.Application.dataPath.."/SimulationTest/"
    local path = dir..ThemeLoader.themeKey..".txt"
    local file = io.open(path, "w")
    if file ~= nil then
        file:write(strFile)
        file:close()
    else
        os.execute("mkdir -p " ..dir)
        os.execute("touch -p "..path)
    end
end

---------------
-- bonus game的仿真。。。
SweetBlastSimulation.m_nTotalCoins = 0
SweetBlastSimulation.m_nSlotsGames = 1 -- 多少个棋盘
SweetBlastSimulation.m_nRowCount = 3
SweetBlastSimulation.m_listWildReelIDs = {}


--SweetBlastBonusGameUI的方法 仿真专用就挪过来放这边了..
function SweetBlastBonusGameUI:BonusGameSimulation()
    SweetBlastLevelParam:setBonusGameInfoEmpty()

    local listAddReelsGridKey = {1, 5, 15} -- ItemType_AddReels
    
    local listFreeSpinNum1Key = {10, 17, 20, 22, 24}
    local listFreeSpinNum2Key = {3, 13}
    local listFreeSpinNum3Key = {7, 26}

    local listWildReelKey = {8, 12, 19, 25}

    local listProbs = {0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.0, 1.0, 1.0}
    -- 大于等于8次freespin就一定概率重新随机..

    while true do
        self:initWheelGingermanSequences()
    
        local nTotalFreeSpinNum = 5 -- 5是初始值
        local bMoreReelsFlag = false
        local bFreeSpinFlag = false -- FreeSpin次数是否满足条件
        local nWildReelNum = 0 -- 不允许等于4 最多只能3

        local listCheckedKeys = {} -- freespin的格子踩过一次之后就变成金币格子了
        
        local param = SweetBlastLevelParam.m_BonusGameInfo
        local cnt = #param.m_listGingermanSequence
        for i=1, cnt do
            local nMapKey = param.m_listGingermanSequence[i]
            local bCheckedFlag = LuaHelper.tableContainsElement(listCheckedKeys, nMapKey)

            local flag = LuaHelper.tableContainsElement(listAddReelsGridKey, nMapKey)
            if flag and (not bCheckedFlag) then
                bMoreReelsFlag = true
                table.insert( listCheckedKeys, nMapKey )
            end
            
            local flag1 = LuaHelper.tableContainsElement(listFreeSpinNum1Key, nMapKey)
            if flag1 and (not bCheckedFlag) then
                nTotalFreeSpinNum = nTotalFreeSpinNum + 1
                table.insert( listCheckedKeys, nMapKey )
            end

            local flag2 = LuaHelper.tableContainsElement(listFreeSpinNum2Key, nMapKey)
            if flag2 and (not bCheckedFlag) then
                nTotalFreeSpinNum = nTotalFreeSpinNum + 2
                table.insert( listCheckedKeys, nMapKey )
            end
            
            local flag3 = LuaHelper.tableContainsElement(listFreeSpinNum3Key, nMapKey)
            if flag3 and (not bCheckedFlag) then
                nTotalFreeSpinNum = nTotalFreeSpinNum + 3
                table.insert( listCheckedKeys, nMapKey )
            end
            
            local flag4 = LuaHelper.tableContainsElement(listWildReelKey, nMapKey)
            if flag4 and (not bCheckedFlag) then
                nWildReelNum = nWildReelNum + 1
                table.insert( listCheckedKeys, nMapKey )
            end
        end

        if nTotalFreeSpinNum < 8 then
            bFreeSpinFlag = true
        else
            local index = nTotalFreeSpinNum - 7
            local prob = listProbs[index]
            if math.random() > prob then
                bFreeSpinFlag = true
            end
        end

        if bMoreReelsFlag and bFreeSpinFlag and (nWildReelNum < 4) then
            break
        end
    end

    local nTotalGingermanNum = 0 -- 本次bonusgame一共获得多少个gingerman
    local nTotalCoins = 0 -- 一共获得多少coins

    local param = SweetBlastLevelParam.m_BonusGameInfo
    param.m_nFreeSpinNum = 5

    local cnt1 = #param.m_listWheelSpinSequence
    local cnt2 = #param.m_listGingermanSequence
    local strWheelColor = tostring(cnt1) .. "  :  "
    for i=1, cnt1 do
        local nWheelKey = param.m_listWheelSpinSequence[i]
       -- local nColorType = self.m_listWheelColorType[nWheelKey]

        local nGingermanNum = 0
        if nWheelKey == 1 then
            nGingermanNum = self.m_listGingermanNum[1]
        elseif nWheelKey == 4 then
            nGingermanNum = self.m_listGingermanNum[2]
        elseif nWheelKey == 7 then
            nGingermanNum = self.m_listGingermanNum[3]
        else
            
        end

        nTotalGingermanNum = nTotalGingermanNum + nGingermanNum
    end

    local tempNum = SweetBlastSimulation.m_nBonusTotalWinGingermanNum + nTotalGingermanNum
    SweetBlastSimulation.m_nBonusTotalWinGingermanNum = tempNum
    -- 这里不加了 调用处根据返回值来加...
    -- local totalnum = SweetBlastLevelParam.m_CollectInfo.m_nCollectNum + nGingermanNum
    -- SweetBlastLevelParam.m_CollectInfo.m_nCollectNum = totalnum
    
    param.m_bAddRowFlag = false
    param.m_WildReelRows = 3
    param.m_nSlotsGameNum = 1

    SweetBlastLevelParam.m_BonusGameInfo.m_nTotalBet = 1
    SweetBlastLevelParam.m_CollectInfo.m_fAvgTotalBet = 1
    
    SweetBlastBonusGameUI:initBonusGameParam() -- 仿真下的初始化
    
    for i=1, cnt2 do
        local nGingermanKey = param.m_listGingermanSequence[i]
        --local nColorType = self.m_listMapColorType[nGingermanKey]
        
        local nType = param.m_listMapItemType[nGingermanKey]
        if nType == self.EnumBonusGameItemType.ItemType_Credit then
            local nCoins = param.m_mapCreditItemValue[nGingermanKey]
            nTotalCoins = nTotalCoins + nCoins

            -- Bonusgame里踩格子赚的
            SweetBlastSimulation.m_fBonusGameGridWin = SweetBlastSimulation.m_fBonusGameGridWin + nCoins
        else
            self:rewardMapKeyBonusSimulation(nGingermanKey)
        end
        
        -- 只要是领过的 都是credit类型
        param.m_listMapItemType[nGingermanKey] = self.EnumBonusGameItemType.ItemType_Credit

    end

    -- Debug.Log("-----BonusGameSimulation----mapCoins--:" .. nTotalCoins)

    SweetBlastSimulation.m_nTotalCoins = nTotalCoins
    SweetBlastSimulation.m_nSlotsGames = param.m_nSlotsGameNum -- 多少个棋盘
    SweetBlastSimulation.m_nRowCount = param.m_WildReelRows

    if param.m_listWildReelKey == nil then
        param.m_listWildReelKey = {}
    end
    SweetBlastSimulation.m_listWildReelIDs = param.m_listWildReelKey
    
    local nFreeSpinType = SweetBlastLevelUI:getFreeSpinTypeByParam(param.m_nSlotsGameNum, param.m_WildReelRows)
    
    local fTotalWin = SweetBlastSimulation:FreeSpinSimu(param.m_nFreeSpinNum, nFreeSpinType, param.m_listWildReelKey)

    -- Bonusgame里最后freespin赚的
    SweetBlastSimulation.m_fBonusGameFreeSpinWin = SweetBlastSimulation.m_fBonusGameFreeSpinWin + fTotalWin

  --  Debug.Log("-----BonusGameSimulation----FreeSpinSimu--:" .. fTotalWin)

    SweetBlastSimulation.m_nTotalCoins = SweetBlastSimulation.m_nTotalCoins + fTotalWin

    -- Debug.Log("-------SimulationBonusGameResult:  ")
    -- Debug.Log("--------nTotalGingermanNum: " .. nTotalGingermanNum)
    -- Debug.Log("--------nTotalCoins: " .. SweetBlastSimulation.m_nTotalCoins)
    -- Debug.Log("--------nSlotsGames: " .. SweetBlastSimulation.m_nSlotsGames)
    -- Debug.Log("--------nRowCount: " .. SweetBlastSimulation.m_nRowCount)
    -- Debug.Log("--------m_listWildReelIDs.Count: " .. #SweetBlastSimulation.m_listWildReelIDs)

    local nTotalFreeSpins = SweetBlastSimulation.m_nBonusGameTotalFreeSpinNum + param.m_nFreeSpinNum
    SweetBlastSimulation.m_nBonusGameTotalFreeSpinNum = nTotalFreeSpins
    SweetBlastSimulation.m_nBonusGameTotalCount = SweetBlastSimulation.m_nBonusGameTotalCount + 1

    return SweetBlastSimulation.m_nTotalCoins, nTotalGingermanNum
end

-- bDelayFlag true : 落在桥上的情况 11 21 
function SweetBlastBonusGameUI:rewardMapKeyBonusSimulation(nGingermanKey)
    -- 1. 调到目标格子了 
    -- 2. 还有传送到下一个格子的情况也在这里把数据更新了。。后面就是视觉表现了，断线不恢复。。

    local param = SweetBlastLevelParam.m_BonusGameInfo

    --领奖励
    local nType = param.m_listMapItemType[nGingermanKey]
    if nType == self.EnumBonusGameItemType.ItemType_Credit then
        -- 这种情况不会来到这里处理

    elseif nType == self.EnumBonusGameItemType.ItemType_AddReels then
        if param.m_nSlotsGameNum == nil then
            param.m_nSlotsGameNum = 1
        end
        param.m_nSlotsGameNum = param.m_nSlotsGameNum + 1

    elseif nType == self.EnumBonusGameItemType.ItemType_FreeSpinAdd1 then
        if param.m_nFreeSpinNum == nil then
            param.m_nFreeSpinNum = 0
        end
        param.m_nFreeSpinNum = param.m_nFreeSpinNum + 1

    elseif nType == self.EnumBonusGameItemType.ItemType_FreeSpinAdd2 then
        if param.m_nFreeSpinNum == nil then
            param.m_nFreeSpinNum = 0
        end
        param.m_nFreeSpinNum = param.m_nFreeSpinNum + 2

    elseif nType == self.EnumBonusGameItemType.ItemType_FreeSpinAdd3 then
        if param.m_nFreeSpinNum == nil then
            param.m_nFreeSpinNum = 0
        end
        param.m_nFreeSpinNum = param.m_nFreeSpinNum + 3

    elseif nType == self.EnumBonusGameItemType.ItemType_WildReel then
        if param.m_listWildReelKey == nil then
            param.m_listWildReelKey = {}
        end
        local nsize = LuaHelper.tableSize(param.m_listWildReelKey)

        local nWildIndex = 0
        if nsize == 0 then
            nWildIndex = 2

        elseif nsize == 1 then
            nWildIndex = 0
            
        elseif nsize == 2 then
            nWildIndex = 4
            
        elseif nsize == 3 then
            nWildIndex = 1
            
        elseif nsize == 4 then
            nWildIndex = 3
            
        end

        table.insert(param.m_listWildReelKey, nWildIndex)
        
    elseif nType == self.EnumBonusGameItemType.ItemType_AddRow then    
        param.m_bAddRowFlag = true
        param.m_WildReelRows = 4
        
    end

    -- 只要是领过的 都是credit类型
    param.m_listMapItemType[nGingermanKey] = self.EnumBonusGameItemType.ItemType_Credit

end

-----------
SweetBlastSimulation.m_fGingermanStoreCoins = 0 -- 获得多少金币
SweetBlastSimulation.m_nBonusGameCount = 0 -- 获得几次BonusGame
SweetBlastSimulation.m_nRespinCount = 0 -- 获得几次ReSpin
SweetBlastSimulation.m_nFullPages = 0 -- 收集满的页数。。满4页又从第一页开始。。奖励对应的freespin

-- 仿真次数满了之后再去Gingerman兑换商店结算一次
function SweetBlastSimulation:GingermanStoreSimulation()
    self.m_nFullPages = 0
    self.m_nRespinCount = 0
    self.m_nBonusGameCount = 0
    self.m_fGingermanStoreCoins = 0

    local param = SweetBlastLevelParam.m_CollectInfo
    param.m_fAvgTotalBet = 1
    local nCurGingermanNum = param.m_nCollectNum

    Debug.Log("------totalNum: " .. nCurGingermanNum)

    local fTotalCoins = 0
    local nPageIndex = 1
    local nOpenedNum = 0
    while true do
        local nCost = SweetBlastGummyBoardUI.m_listMissionGummies[nPageIndex]
        nCurGingermanNum = nCurGingermanNum - nCost
        if nCurGingermanNum < nCost then

          --  param.m_nCollectNum = 0

            param.m_nCollectNum = nCurGingermanNum -- 这个可能是负数了.. 不过没关系

            break
        end

        nOpenedNum = nOpenedNum + 1
        if nOpenedNum == 4 then
            self.m_nBonusGameCount = self.m_nBonusGameCount + 1
        elseif nOpenedNum == 8 then
            self.m_nRespinCount = self.m_nRespinCount + 1
        else
            -- 假设每次开金币箱子都是得到 1.5
            self.m_fGingermanStoreCoins = self.m_fGingermanStoreCoins + 1.5
            self.m_fGingermanStoreBoxWin = self.m_fGingermanStoreBoxWin + 1.5
        end
        
        if nOpenedNum == 9 then
            nOpenedNum = 0
            self.m_nFullPages = self.m_nFullPages + 1
            Debug.Log("-------nPageIndex: " .. nPageIndex .. "  ----nCost: " .. nCost)
            Debug.Log("-------nCurGingermanNum: " .. nCurGingermanNum)

            nPageIndex = nPageIndex + 1
            if nPageIndex > 4 then
                nPageIndex = 1
            end
        end

    end

    for i=1, self.m_nFullPages do
        local nPageIndex = math.floor( i % 4 )
        if nPageIndex == 0 then
            nPageIndex = 4
        end

        local fWin = self:RewardFullPageBonusSimulation(nPageIndex)
        self.m_fGingermanStoreCoins = self.m_fGingermanStoreCoins + fWin

        self.m_fGingermanStoreFullFreeSpinWin = self.m_fGingermanStoreFullFreeSpinWin + fWin
    end

    for i=1, self.m_nRespinCount do
        local deck = {}
        for key=0, 19 do
            deck[key] = 6
        end
        local fWin = self:ReSpinSimu(deck)
        self.m_fGingermanStoreCoins = self.m_fGingermanStoreCoins + fWin
        self.m_fGingermanStoreRespinWin = self.m_fGingermanStoreRespinWin + fWin
    end

    local unUsedGingerman = 0
    for i=1, self.m_nBonusGameCount do
        local fWin, nGingermanNum = SweetBlastBonusGameUI:BonusGameSimulation()
        self.m_fGingermanStoreCoins = self.m_fGingermanStoreCoins + fWin

        self.m_fBonusGameTotalWin = self.m_fBonusGameTotalWin + fWin
        self.m_fGingermanStoreBonusGameWin = self.m_fGingermanStoreBonusGameWin + fWin

        unUsedGingerman = unUsedGingerman + nGingermanNum
    end
    Debug.Log("--------unUsedGingerman-------: " .. unUsedGingerman)

    Debug.Log("-----------fGingermanStoreCoins: " .. self.m_fGingermanStoreCoins)
    Debug.Log("-----------nBonusGameCount: " .. self.m_nBonusGameCount)
    Debug.Log("-----------nRespinCount: " .. self.m_nRespinCount)
    Debug.Log("-----------nFullPages: " .. self.m_nFullPages)

    self.m_fGingermanStoreTotalWin = self.m_fGingermanStoreTotalWin + self.m_fGingermanStoreCoins
    return self.m_fGingermanStoreCoins
end

function SweetBlastSimulation:RewardFullPageBonusSimulation(nPageIndex) -- 兑换满一页领取freespin大奖
    -- nPageIndex 1 2 3 4
    -- 15  15  15  8
    local nFreeSpinNum = SweetBlastGummyBoardUI.m_listSuperFreeSpins[nPageIndex]
    local listWildReelID = {}
    local nFreeSpinType = 0

    local fFreeSpinBet = 1

    if nPageIndex == 1 then
        nFreeSpinType = EnumSweetBlastFreeSpinType.FreeSpin4X5_2
        listWildReelID = {1, 3}

    elseif nPageIndex == 2 then
        nFreeSpinType = EnumSweetBlastFreeSpinType.FreeSpin4X5_3
        listWildReelID = {1, 3}

    elseif nPageIndex == 3 then
        nFreeSpinType = EnumSweetBlastFreeSpinType.FreeSpin4X5_3
        listWildReelID = {2, 3, 4}

    elseif nPageIndex == 4 then
        nFreeSpinType = EnumSweetBlastFreeSpinType.FreeSpin4X5_4
        listWildReelID = {1, 2, 3, 4}

    else

    end
    
    -- 仿真freespin...
    local fTotalWin = self:FreeSpinSimu(nFreeSpinNum, nFreeSpinType, listWildReelID)
    return fTotalWin
end

-- FreeSpin 仿真 -- 输入各种参数 返回获得的金币值
function SweetBlastSimulation:FreeSpinSimu(nFreeSpinNum, nFreeSpinType, listWildReelID)
    if #listWildReelID > 3 then
        Debug.Log("----listWildReelID.count--------: " .. #listWildReelID)
    end

    local fTotalWin = 0
    if nFreeSpinType <= 3 then -- 3X5
        fTotalWin = FreeSpinData3X5:getFreeSpinSimuResult(nFreeSpinNum, nFreeSpinType, listWildReelID)
    else --4X5
        fTotalWin = FreeSpinData4X5:getFreeSpinSimuResult(nFreeSpinNum, nFreeSpinType, listWildReelID)
    end

    self.m_fAllFreeSpinWinCoins = self.m_fAllFreeSpinWinCoins + fTotalWin

    if fTotalWin > 150 then
        Debug.Log("------#listWildReelID: " .. #listWildReelID .. "  ----fTotalWin: " .. fTotalWin)
    end

    return fTotalWin
end

-- Respin 仿真 。。。
function SweetBlastSimulation:ReSpinSimu(deck)
    -- 返回respin一共赢得多少..
    --
    local nRespinCount = 3
    local listStickyKeys = {}
    local nCollectID = SlotsGameLua:GetSymbolIdByObjName("CollectElem")

    for x=0, 4 do
        for y=0, 3 do
            local nkey = 4 * x + y
            if deck[nkey] == nCollectID then
                table.insert(listStickyKeys, nkey)
            end
        end
    end

    while nRespinCount > 0 do
        nRespinCount = nRespinCount - 1

        for x=0, 4 do
            for y=0, 3 do
                local nSymbolID = SlotsGameLua.m_randomChoices:ChoiceSymbolId(x)
                local nkey = 4 * x + y
                deck[nkey] = nSymbolID
            end
        end
        
        -- 加减概率...
        self:modifyCollectElemProbSimu(deck, listStickyKeys)

        local nAddCollectNum = 0 -- 新加了几个固定元素
        for key=0, 19 do
            if deck[key] == nCollectID then
                local flag = LuaHelper.tableContainsElement(listStickyKeys, key)
                if not flag then
                    table.insert( listStickyKeys, key )
                    nAddCollectNum = nAddCollectNum + 1
                end
            end
        end
        if nAddCollectNum > 0 then
            nRespinCount = 3 -- 有新固定元素 重置respin到3次
        end
        Debug.Assert(nAddCollectNum < 4, tostring(nAddCollectNum) .. "-----error!!----")

        -- 简化了 变一个 变8个 playitagain 的逻辑

        if #listStickyKeys == 20 then -- 收满了...
            Debug.Log("---!!!!!!!!!!------CollectFull---------!!!!---")
            break
        end
    end

    local fWin = 0 -- 本次respin一共赢得多少..
    local value = 0
    for i=1, #listStickyKeys do
        local fProb = math.random()
        if fProb < 0.06 then
            value = SweetBlastFunc.CollectValueType.MiniType
            fWin = fWin + 5 + 5
        elseif fProb < 0.07 then
            value = SweetBlastFunc.CollectValueType.MinorType
            fWin = fWin + 10 + 10
        elseif fProb < 0.075 then
            value = SweetBlastFunc.CollectValueType.MajorType
            fWin = fWin + 25 + 25
        elseif fProb < 0.085 then
            value = SweetBlastFunc.CollectValueType.PlayItAgainType -- 只会出一个
            fWin = fWin + 25
        elseif fProb < 0.095 then
            value = SweetBlastFunc.CollectValueType.AddAllAdjacentsType -- 周围8个。。
            fWin = fWin + 8
        elseif fProb < 0.12 then
            value = SweetBlastFunc.CollectValueType.AddAnAdjacentType -- 周围1个。。
            fWin = fWin + 2
        else
            local listProbs = {300, 200, 200, 100, 100, 75, 75, 50, 50, 25, 25, 10, 10, 5, 3, 2}
            local nIndex = LuaHelper.GetIndexByRate(listProbs)
            local fCoef = SweetBlastFunc.m_listCollectElemCoinCoefs[nIndex]
            value = fCoef -- totalbet 的倍数
            fWin = fWin + fCoef
        end
    end

    if #listStickyKeys == 20 then
        fWin = fWin + 100 -- 获得Grand大奖
    end

    self.m_nTotalRespinCount = self.m_nTotalRespinCount + 1
    self.m_nTotalRespinCollectNum = self.m_nTotalRespinCollectNum + #listStickyKeys
    
    return fWin
end

-- listStickyKeys 已经固定的元素..
function SweetBlastSimulation:modifyCollectElemProbSimu(deck, listStickyKeys)
    -- 1. 从11个开始减少概率。。
    local decProbs = {5, 15, 25, 35, 50, 60, 70, 80, 90, 95}
    -- 从1个开始增加收集概率。。playitagain 或者 开箱子游戏里获得的respin都是从0个开始收集的。。
    -- 2. 5个以内都适当增加收集概率
    local incProbs = {10, 10, 10, 5, 5}

    -- 3. 一次不要收集超过3个元素。。
    local nCollectElem = SlotsGameLua:GetSymbolIdByObjName("CollectElem")
    local nStickyNum = #listStickyKeys -- 返回已经固定的元素个数

    local normalElemKeys = {}
    local newCollectElemKeys = {}
    for x = 0, 4 do
        local reel = SlotsGameLua.m_listReelLua[x]

        for y = 0, 3 do
            local nkey = 4 * x + y
            local nSymbolID = deck[nkey]
            local type = SlotsGameLua:GetSymbol(nSymbolID).type
            local bres = LuaHelper.tableContainsElement(listStickyKeys, nkey)
            if not bres then
                if type == SymbolType.Normal then
                    table.insert(normalElemKeys, nkey)
                elseif nSymbolID == nCollectElem then
                    table.insert(newCollectElemKeys, nkey) -- 新加入的收集元素
                end
            end
            
        end
    end

    newCollectElemKeys = LuaThemeVideo2020Helper.shuffle(newCollectElemKeys)
    local nAddNum = #newCollectElemKeys
    -- 增加的概率
    if (nStickyNum <= 5) and (nAddNum == 0) then
        local fProb = 20
        if nStickyNum > 0 then
            fProb = incProbs[nStickyNum]
        end

        for i=1, #normalElemKeys do
            local key = normalElemKeys[i]
            if math.random(1, 100) < fProb then
                deck[key] = nCollectElem
                break -- 加一个就行了
            end
        end
    end

    local nMaxCollectElemIndex = nAddNum
    if nAddNum > 3 then -- 超过3个的替换成普通元素
        nMaxCollectElemIndex = 3
        for i=4, nAddNum do
            local key = newCollectElemKeys[i]
            deck[key] = math.random(1, 8)
        end
    end

    --减少 收集的概率
    if (nStickyNum >= 11) and (nAddNum > 0) then
        local fProb = decProbs[nStickyNum-10]

        for i=1, nMaxCollectElemIndex do
            local key = newCollectElemKeys[i]
            if math.random(1, 100) < fProb then
                deck[key] = math.random(1, 8)
            end
        end
    end
    
end

function SweetBlastSimulation:getGingermanNum(deck)
    local nGingermanNum = 0
    local nTotal = #SweetBlastFunc.m_listGingermanLogoElemKeys
    
    for i=1, nTotal do
        local num = SweetBlastFunc:getGingermanNum()
        nGingermanNum = nGingermanNum + num
    end
    
    return nGingermanNum
end

function SweetBlastSimulation:getSpinWinSimu(deck, rt)
    -- 这次spin赢得多少..
    local fWin = 0
    local bTriggerRespinFlag = SweetBlastFunc:isTriggerRespin(deck)
    if bTriggerRespinFlag then
        fWin = self:ReSpinSimu(deck)

        rt.m_fGameWin = rt.m_fGameWin + fWin

        self.m_nBaseGameTriggerRespinNum = self.m_nBaseGameTriggerRespinNum + 1
        self.m_fBaseRespinTotalWin = self.m_fBaseRespinTotalWin + fWin
        return fWin
    end

    local param = SweetBlastLevelParam.m_CollectInfo
    local bTriggerBonusGame = SweetBlastFunc:isTriggerBonusGame(deck)
    if bTriggerBonusGame then
        local fWin, nGingermanNum = SweetBlastBonusGameUI:BonusGameSimulation()

        rt.m_fGameWin = rt.m_fGameWin + fWin
        
        param.m_nCollectNum = param.m_nCollectNum + nGingermanNum

        self.m_nBaseGameTriggerBonusGameNum = self.m_nBaseGameTriggerBonusGameNum + 1
        self.m_fBaseBonusGameTotalWin = self.m_fBaseBonusGameTotalWin + fWin

        self.m_fBonusGameTotalWin = self.m_fBonusGameTotalWin + fWin

        return fWin
    end

    local nGingermanNum = self:getGingermanNum(deck)
    param.m_nCollectNum = param.m_nCollectNum + nGingermanNum

    -- base game 中奖计算
    SweetBlastFunc:CheckSpinWinPayLines(deck, rt)

    self.m_fBaseTotalWin = self.m_fBaseTotalWin + rt.m_fSpinWin

    return rt.m_fSpinWin
    --
end
