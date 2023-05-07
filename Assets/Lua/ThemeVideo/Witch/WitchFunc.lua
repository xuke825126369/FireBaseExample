require "Lua/ThemeVideo/Witch/WitchLevelUI"
require "Lua/ThemeVideo/Witch/WitchCustomDeck"
require "Lua/ThemeVideo/Witch/WitchConfig"
require "Lua/ThemeVideo/Witch/WitchSymbol"

WitchFunc = {}

function WitchFunc:InitVariable()
    -------------------------游戏变量--------------------
    self.m_listHitSymbols = {}
    self.m_nWin0Count = 0
    self.m_bScatterSound = false
    self.fResultAniTime = 0.0 --结算时 动画播放 时间

    self.tableCollectElementType = {}
    self.tableReSpinFixedCollectSymbol = {}

    self.nReSpinCurrentReelCount = 5 --假设的ReSpin 的列数
    self.nReSpinCurrentRowCount = 3 -- 假设的 ReSpin 的 行数
    self.fReSpinCollectMoneyCount = 0

    self.nReSpinFixedSymbolOrder = -18
    self.nNormalSpinCollectSymbolOrder = -25

    self.nNoBigSymbolGrid = 0

    ------------------------- 仿真数据 --------------------
    self.m_bSimulationFlag = false
    self.m_nSimulationCount = 0 -- 仿真统计专用

    -- 不中奖
    self.m_nSimuWin0SpinNum = 0.0

    -- 统计 中大奖
    self.m_nSimuBigMultuileCount = 0
    self.m_nSimuBigMultuileMoneyCount = 0
    self.m_nSimuReSpinBigMultuileCount = 0
    self.m_nSimuReSpinBigMultuileMoneyCount = 0

    -- FreeSpin 相关
    self.m_nSimuFreeSpinCount = 0
    self.m_nSimuFreeSpinTriggerCount = 0 
    self.m_nSimuFreeSpinMoneyCount = 0

    -- ReSpin 相关
    self.m_nSimuReSpinCount = 0
    self.m_nSimuFreeSpinReSpinTriggerCount = 0
    self.m_nSimuFreeSpinReSpinMoneyCount = 0

    self.m_nSimuNormalReSpinTriggerCount = 0
    self.m_nSimuNormalReSpinMoneyCount = 0

    self.m_nSimuReSpinTriggerCount = 0
    self.m_nSimuReSpinMoneyCount = 0
    self.m_nSimuReSpinAverageCollectCount = 0
    self.m_nSimuReSpinAwardInfo = {}
    self.m_nSimuJackPotAwardInfo = {}

    self.m_nSimuJackPotGrandCount = 0
    self.m_nSimuJackPotGrandMoneyCount = 0
end

--开始滚动的时候 显示静帧 隐藏spine节点
--准备结算的时候 显示静帧 显示spine节点
function WitchFunc:showSpineFrame0(bShowFrame0)
    -- 2018-6-14 显示spine节点只显示需要播放中奖特效的
    if not bShowFrame0 then
        self:showSpineNode()
    else
        for x=0, SlotsGameLua.m_nReelCount-1 do
            local reel = SlotsGameLua.m_listReelLua[x]
            for y=0, SlotsGameLua.m_nRowCount - 1 do

                local goSymbol = nil
                local bStickyFlag, nStickyIndex = reel:isStickyPos(y)
                if bStickyFlag then
                    goSymbol = reel.m_listStickySymbol[nStickyIndex].m_goSymbol
                else
                    goSymbol = reel.m_listGoSymbol[y]
                end
                
                local goFrame0 = SymbolObjectPool.m_mapSpineElemFrame0[goSymbol]
                if goFrame0 ~= nil then
                    local goSpineNode = SymbolObjectPool.m_mapSpineNode[goSymbol]
                    local spineEffect = SymbolObjectPool.m_mapSpinEffect[goSymbol]
                        
                    if bShowFrame0 then
                        goFrame0:SetActive(true)
                        -- 要隐藏spineNode的时候 检查是否在播放 如果在播放 需要先停止播放
                        if spineEffect ~= nil then
                            spineEffect:StopActiveAnimation()
                        end
                        goSpineNode:SetActive(false)
                    else
                        --显示spine节点 隐藏静帧
                        goSpineNode:SetActive(true)
                        spineEffect:Reset()
                    end

                end
            end

        end
    end

end

function WitchFunc:showSpineNode() -- 滚动停止的时候调用
    local cnt = #self.m_listHitSymbols
    for i = 1, cnt do
        local nKey = self.m_listHitSymbols[i]
        local x = math.floor( nKey / SlotsGameLua.m_nRowCount)
        local y = nKey % SlotsGameLua.m_nRowCount

        local reel = SlotsGameLua.m_listReelLua[x]
        local goSymbol = nil
        local bStickyFlag, nStickyIndex = reel:isStickyPos(y)
        if bStickyFlag then
            goSymbol = reel.m_listStickySymbol[nStickyIndex].m_goSymbol
        else
            goSymbol = reel.m_listGoSymbol[y]
        end

        local goSpineNode = SymbolObjectPool.m_mapSpineNode[goSymbol]
        local spineEffect = SymbolObjectPool.m_mapSpinEffect[goSymbol]
        local goFrame0 = SymbolObjectPool.m_mapSpineElemFrame0[goSymbol]
        if goSpineNode ~= nil then
            --显示spine节点 隐藏静帧
            goSpineNode:SetActive(true)
            --spineEffect:Reset()
            CoroutineHelper.waitForEndOfFrame(function()
                goFrame0:SetActive(false)
            end)
        end
    end
    
    self.m_listHitSymbols = {}
end

function WitchFunc:refreshHitSymbols(nLineId, nMaxMatchId) -- 还应该包括进wild牌..
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        if x <= nMaxMatchId then
            local reel = SlotsGameLua.m_listReelLua[x]

            local y = SlotsGameLua:GetLine(nLineId).Slots[x]
            local nKey = SlotsGameLua.m_nRowCount * x + y

            local bflag = LuaHelper.tableContainsElement(self.m_listHitSymbols, nKey)
            if not bflag then
                table.insert( self.m_listHitSymbols, nKey )
            end
        end
    end
end

function WitchFunc:OnStartSpin()
    self:showSpineFrame0(true)
    self.m_bScatterSound = false

    self.nNoBigSymbolGrid = 0

    if SlotsGameLua.m_GameResult:InReSpin() then
        WitchLevelUI:SetReSpinRemainCount(SlotsGameLua.m_GameResult.m_nReSpinTotalCount - SlotsGameLua.m_GameResult.m_nReSpinCount - 1)
    else
        local bNeedResetJackPotValue = false
        for i = 1, #WitchLevelUI.tableNowbGetJackPot do
            if WitchLevelUI.tableNowbGetJackPot[i] then
                bNeedResetJackPotValue = true
                break
            end
        end 

        if bNeedResetJackPotValue then
            WitchLevelUI.mJackPotUI:modifyJackpotValueByTotalBet()
            for i = 1, #WitchLevelUI.tableNowbGetJackPot do
                WitchLevelUI.tableNowbGetJackPot[i] = false
            end
        end
    end

end 

function WitchFunc:OnSpinEnd()
    self:showSpineFrame0(false)
    WitchLevelUI:PlayFreeSpinBigSymbolEffect()
end

function WitchFunc:GetDeck()
    local rt = SlotsGameLua.m_GameResult
    if self.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local bReSpinFlag = rt:InReSpin()
    local bFreeSpinFlag = rt:InFreeSpin()

    local deck = {}
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        for y = 0, SlotsGameLua.m_nRowCount - 1 do
            local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(x)
            local nKey = SlotsGameLua.m_nRowCount * x + y
            deck[nKey] = nSymbolId
        end
    end

    if bReSpinFlag then
        WitchCustomDeck:RespinReStoreCollectRecord(deck)
        WitchCustomDeck:ModifyReSpinCollectElementProb(deck)
        WitchCustomDeck:DoRespinCollectRecord(deck)
    else
        WitchCustomDeck:modifyDeckForWildStack(deck)

        WitchCustomDeck:ModifyDeckForWin0(deck)

        WitchCustomDeck:modifyDeckForTriggerFreeSpin(deck)
        WitchCustomDeck:modifyDeckForFreeSpin(deck)

        WitchCustomDeck:RespinReStoreCollectRecord(deck)
        WitchCustomDeck:ModifyDeckForTriggerRespin(deck)
        WitchCustomDeck:DoRespinCollectRecord(deck)
    end

    self:ModifyTestDeck(deck)

    return deck
end

function WitchFunc:ModifyTestDeck(deck)
    if not GameConfig.PLATFORM_EDITOR then
        return
    end
    
    if self.m_bSimulationFlag then
        return
    end
end

function WitchFunc:CreateReelRandomSymbolList()
    local nScatterSymbolId = SlotsGameLua:GetSymbolIdByObjName("Scatter")

    local cnt = 50
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID = {}
        SlotsGameLua.m_listReelLua[x].m_nCurRandomIDIndex = 1

        for i = 1, cnt do
            local nSymbolId = SlotsGameLua.m_randomChoices:ChoiceSymbolId(x)
            SlotsGameLua.m_listReelLua[x].m_listRandomSymbolID[i] = nSymbolId
        end

    end

end

-- 这里设置 收集符号的 类型，层级，Mask
function WitchFunc:SymbolCustomHandler(nReelId, nRowIndex, bResultDeck, nDeckKey)
    local reel = SlotsGameLua.m_listReelLua[nReelId]
	local goSymbol = reel.m_listGoSymbol[nRowIndex]
    local nSymbolId = reel.m_curSymbolIds[nRowIndex]

    if WitchSymbol:isReSpinCollectSymbol(nSymbolId) then
        if bResultDeck then
            local nType = self.tableCollectElementType[nDeckKey][2]
            local nMoneyMultuile = self.tableCollectElementType[nDeckKey][3]
            WitchLevelUI:SetCollectSymbol(goSymbol, nType, nMoneyMultuile, nReelId)
        else
            local nType, nMoneyMultuile = self:GetRandomReSpinCollectType()
            WitchLevelUI:SetCollectSymbol(goSymbol, nType, nMoneyMultuile, nReelId)
        end  
        
        CoroutineHelper.waitForEndOfFrame(function()
            if SlotsGameLua.m_GameResult:InReSpin() or self:bCanTriggerReSpin(SlotsGameLua.m_listDeck) then
                WitchLevelUI:SetModifyLayer(goSymbol, self.nReSpinFixedSymbolOrder)
            else
                WitchLevelUI:SetModifyLayer(goSymbol, self.nNormalSpinCollectSymbolOrder)
            end 
        end)
    end

end

function WitchFunc:isReelCanStartDeck(nReelId)
    if SlotsGameLua.m_GameResult:InFreeSpin() then
        return self.nNoBigSymbolGrid == 0
    else
        return true
    end
end

function WitchFunc:GetRandomReSpinCollectType()
    local tableTypeRate = {15, 10, 5, 150}

    local nType = LuaHelper.GetIndexByRate(tableTypeRate)
    local nIndex = math.random(1, #WitchConfig.TABLE_RESPIN_COLLECT_MONEY_MULTUILE)
    local nMoneyMultuile = WitchConfig.TABLE_RESPIN_COLLECT_MONEY_MULTUILE[nIndex]

    return nType, nMoneyMultuile
end

function WitchFunc:GetCurrentCurveGroup(nReelId)
    local targetGroup = nil
    if WitchLevelUI.bUseReSpinCurveGroup then
        local nIndex = nReelId % self.nReSpinCurrentRowCount
        if WitchLevelUI.mLeveData_ReSpin.tableCurveGroup and WitchLevelUI.mLeveData_ReSpin.tableCurveGroup[nIndex] then
            targetGroup = WitchLevelUI.mLeveData_ReSpin.tableCurveGroup[nIndex]
        else
            Debug.Assert(false, nIndex)
        end
    else
        targetGroup = WitchLevelUI.mDefaultCurveGroup
    end

    Debug.Assert(targetGroup)

    return targetGroup
end

function WitchFunc:CheckSpawnSymbol(nSymbolId, nReelId, nRowIndex)
    local targetGroup = self:GetCurrentCurveGroup(nReelId)

    if WitchLevelUI.bUseReSpinCurveGroup then
        return self:SpawnSymbolByCurveGroup(nSymbolId, targetGroup)
    end

    if SlotsGameLua.m_GameResult:InFreeSpin() then
        if nReelId == 2 then
            self.nNoBigSymbolGrid = self.nNoBigSymbolGrid + 1
            self.nNoBigSymbolGrid = self.nNoBigSymbolGrid % 3
            
            if self.nNoBigSymbolGrid == 2 then
                local prefab = WitchLevelUI.tableBigSymbolPool[nSymbolId]
                return WitchLevelUI:SpawnSymbolToSymbolPool(targetGroup, prefab)
            else
                local goSymbol = self:SpawnSymbolByCurveGroup(nSymbolId, targetGroup)
                goSymbol:SetActive(false)
                return goSymbol
            end
        elseif nReelId >= 1 and nReelId <= 3 then
            local goSymbol = self:SpawnSymbolByCurveGroup(nSymbolId, targetGroup)
            goSymbol:SetActive(false)
            return goSymbol
        end
    end 

    return self:SpawnSymbolByCurveGroup(nSymbolId, targetGroup)
end 

function WitchFunc:SpawnSymbolByCurveGroup(nSymbolId, targetGroup)
    local prefab = SlotsGameLua:GetSymbol(nSymbolId).prfab
    return WitchLevelUI:SpawnSymbolToSymbolPool(targetGroup, prefab)
end

function WitchFunc:isStopReel(nReelIndex)
    if SlotsGameLua.m_GameResult:InReSpin() then
        local nKey = nReelIndex
        return self.tableReSpinFixedCollectSymbol[nKey]
    end

    return false
end

function WitchFunc:ReDeckForReSpinFixedSymbol(deck)
    for k, v in pairs(self.tableReSpinFixedCollectSymbol) do
        deck[k] = v[1]
        self.tableCollectElementType[k] = {v[1], v[2], v[3]}
    end
end

function WitchFunc:PreCheckWin()
    SlotsGameLua:CheckWinEnd()
end

function WitchFunc:CheckGameResult(deck, result)
    self:CheckReSpin(deck, result)
    if not result:InReSpin() then
        self:CheckFreeSpin(deck, result)
    end
end

function WitchFunc:bCanTriggerReSpin(deck)
    local rt = SlotsGameLua.m_GameResult
    if WitchFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    if rt:InReSpin() then
        return false
    end

    local nCount = 0
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            local nSymbolId = deck[nKey]

            if WitchSymbol:isReSpinCollectSymbol(nSymbolId) then
                nCount = nCount + 1
            end
        end 
    end

    return nCount >= WitchConfig.N_RESPIN_TRIGGER_MIN_COLLECTCOUNT
end

function WitchFunc:GetScatterCount(deck)
    local nScatterSymbolId = SlotsGameLua:GetSymbolIdByObjName("Scatter")

    local nScatterCount = 0
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            if deck[nKey] == nScatterSymbolId then
                nScatterCount = nScatterCount + 1
                break
            end
        end
    end

    return nScatterCount
end

function WitchFunc:bCanTriggerFreeSpin(deck)
    local nScatterCount = self:GetScatterCount(deck)
    return nScatterCount >= WitchConfig.N_FREESPIN_TRIGGER_MIN_SCATTERCOUNT, nScatterCount
end

function WitchFunc:CheckReSpin(deck, result)
    local bShowReSpinBeginSplashUI = false
    local bShowReSpinFinishSplashUI = false

    if result:InReSpin() then
        local nAddUsefulCount = 0
        for i = 0, SlotsGameLua.m_nReelCount - 1 do
            for j = 0, SlotsGameLua.m_nRowCount - 1 do
                local nKey = i * SlotsGameLua.m_nRowCount + j
                local nSymbolId = deck[nKey]

                if WitchSymbol:isReSpinCollectSymbol(nSymbolId) and not self.tableReSpinFixedCollectSymbol[nKey] then
                    local nType = self.tableCollectElementType[nKey][2]
                    local nMoneyMultuile = self.tableCollectElementType[nKey][3]
                    self.tableReSpinFixedCollectSymbol[nKey] = {nSymbolId, nType, nMoneyMultuile}

                    nAddUsefulCount = nAddUsefulCount + 1
                end
            end
        end  

        if LuaHelper.tableSize(self.tableReSpinFixedCollectSymbol) == SlotsGameLua.m_nReelCount * SlotsGameLua.m_nRowCount then
            result.m_nReSpinCount = result.m_nReSpinTotalCount
        elseif nAddUsefulCount > 0 then
            result.m_nReSpinCount = 0
            result.m_nReSpinTotalCount = WitchConfig.N_RESPIN_TRIGGER_FREECOUNT 
            if not self.m_bSimulationFlag then
                WitchLevelUI:SetReSpinRemainCount(result.m_nReSpinTotalCount)
                AudioHandler:PlayThemeSound("respin_reset")
            end
        end
        
        if result:HasReSpin() then
            if not self.m_bSimulationFlag then
                SlotsGameLua.m_bAnimationTime = true
                LeanTween.delayedCall(0.5, function()
                    SlotsGameLua.m_bAnimationTime = false
                end)
            end
        else
            if not self.m_bSimulationFlag then
                bShowReSpinFinishSplashUI = true
            end
        end     

        if not self.m_bSimulationFlag then
            WitchLevelUI:setDBReSpin()
        end

    else
        local bTriggerReSpin = self:bCanTriggerReSpin(deck)

        if bTriggerReSpin then
            result.m_nReSpinCount = 0
            result.m_nReSpinTotalCount = WitchConfig.N_RESPIN_TRIGGER_FREECOUNT 

            self.fReSpinCollectMoneyCount = 0
            self.tableReSpinFixedCollectSymbol = {}

            for i = 1, 4 do
                WitchLevelUI.tableNowbGetJackPot[i] = false
                WitchLevelUI.tableNowJackPotMoneyCount[i] = WitchLevelUI.mJackPotUI:GetTotalJackPotValue(i)
            end 

            for i = 0, SlotsGameLua.m_nReelCount - 1 do
                for j = 0, SlotsGameLua.m_nRowCount - 1 do
                    local nKey = i * SlotsGameLua.m_nRowCount + j
                    local nSymbolId = deck[nKey]

                    if WitchSymbol:isReSpinCollectSymbol(nSymbolId) then
                        local nType = self.tableCollectElementType[nKey][2]
                        local nMoneyMultuile = self.tableCollectElementType[nKey][3]
                        self.tableReSpinFixedCollectSymbol[nKey] = {nSymbolId, nType, nMoneyMultuile}
                    end
                end
            end  

            if not self.m_bSimulationFlag then
                bShowReSpinBeginSplashUI = true
            end
            
            if self.m_bSimulationFlag then
                self.m_nSimuReSpinTriggerCount = self.m_nSimuReSpinTriggerCount + 1
                if result:InFreeSpin() then
                    self.m_nSimuFreeSpinReSpinTriggerCount = self.m_nSimuFreeSpinReSpinTriggerCount + 1
                else
                    self.m_nSimuNormalReSpinTriggerCount = self.m_nSimuNormalReSpinTriggerCount + 1
                end

                self:SimulationReSpinBegin()
            end     

            if not self.m_bSimulationFlag then
                WitchFunc.bInReSpin = true
                
                WitchLevelUI:setDBReSpin()
                WitchLevelUI:setDBReSpinForFixedSymbol()
            end

        end 

    end         

    if not self.m_bSimulationFlag then
        if bShowReSpinBeginSplashUI then
            SlotsGameLua.m_bSplashFlags[SplashType.ReSpin] = true
        end

        if bShowReSpinFinishSplashUI then
            SlotsGameLua.m_bSplashFlags[SplashType.ReSpinEnd] = true
        end
    end
    
end

function WitchFunc:CheckFreeSpin(deck, result)
    local bTrigger, nScatterCount = self:bCanTriggerFreeSpin(deck)
        
    if bTrigger then
        local nFreeSpinCounnt = WitchConfig.TABLE_FREESPIN_TRIGGER_FREECOUNT[nScatterCount]

        result.m_nNewFreeSpinCount = nFreeSpinCounnt
        result.m_nFreeSpinTotalCount = result.m_nFreeSpinTotalCount + nFreeSpinCounnt

        if self.m_bSimulationFlag then
            self.m_nSimuFreeSpinTriggerCount = self.m_nSimuFreeSpinTriggerCount + 1
        end
    end

end

function WitchFunc:FillSymbol(nSymbolId, nReelId, nRowIndex)
    local preGoSymbol = SlotsGameLua.m_listReelLua[nReelId].m_listGoSymbol[nRowIndex]
    if preGoSymbol then
        SymbolObjectPool:Unspawn(preGoSymbol)
    else
        Debug.LogError("nReelId: "..nReelId.." nRowIndex: "..nRowIndex)
    end
        
    local newGO = LevelCommonFunctions:SpawnSymbol(nSymbolId, nReelId, nRowIndex)
    newGO.transform:SetParent(SlotsGameLua.m_listReelLua[nReelId].m_transform, false)
    newGO.transform.localScale = Unity.Vector3.one
    newGO.transform.localPosition = SlotsGameLua.m_listReelLua[nReelId].m_listSymbolPos[nRowIndex]

    SlotsGameLua.m_listReelLua[nReelId].m_listGoSymbol[nRowIndex] = newGO
    SlotsGameLua.m_listReelLua[nReelId].m_curSymbolIds[nRowIndex] = nSymbolId

    return newGO
end

function WitchFunc:FixedReSpinCollectSymbol(nReelId, nRowIndex)
    local nKey = nReelId * SlotsGameLua.m_nRowCount + nRowIndex
    local nSymbolId = SlotsGameLua.m_listReelLua[nReelId].m_curSymbolIds[nRowIndex]
    WitchLevelUI:HideReelAllSymbol(nReelId)

    local goSymbol = self:SpawnSymbolByCurveGroup(nSymbolId, WitchLevelUI.mMergeSymbolGroup)
    local newSymbolParent = WitchLevelUI.mMergeSymbolGroup.transform
    goSymbol.transform:SetParent(newSymbolParent, false)
    goSymbol.transform.position =  WitchLevelUI.mLeveData_ReSpin.tableCachePos[nKey]

    local fOrderZ = LevelCommonFunctions:getSymbolOrderZ(nReelId, nRowIndex)
    goSymbol.transform.localPosition =  Unity.Vector3(goSymbol.transform.localPosition.x, goSymbol.transform.localPosition.y, fOrderZ)
    goSymbol.transform.localScale = Unity.Vector3.one

    WitchLevelUI.tableReSpinFixedCollectGoSymbol[nKey] = goSymbol
    
    local nType = self.tableCollectElementType[nKey][2]
    local nMoneyMultuile = self.tableCollectElementType[nKey][3]
    WitchLevelUI:SetCollectSymbol(goSymbol, nType, nMoneyMultuile, nReelId)

    CoroutineHelper.waitForEndOfFrame(function()
        WitchLevelUI:SetModifyLayer(goSymbol, self.nReSpinFixedSymbolOrder) 
    end)

    return goSymbol
end

function WitchFunc:CancelAllReSpinFixedSymbol()
    self.tableReSpinFixedCollectSymbol = {}
end

function WitchFunc:GetReSpinMoneyCount(result)
    local fReSpinCollectMoneyCount = 0

    for k, v in pairs(self.tableReSpinFixedCollectSymbol) do
        local bUseful = true
        if result:InFreeSpin() then
            local nFakeReelId = math.floor(k / self.nReSpinCurrentRowCount)
            local nFakeRowIndex = k % self.nReSpinCurrentRowCount

            if nFakeReelId >= 1 and nFakeReelId <= 3 then
                if not (nFakeReelId == 2 and nFakeRowIndex == 1) then
                    bUseful = false
                end
            end
        end
        
        if bUseful then
            local nType = v[2] 
            local nMoneyMultuile = v[3] 

            local fAddMoneyCount = 0
            if nType == 4 then
                fAddMoneyCount = SceneSlotGame.m_nTotalBet * nMoneyMultuile
            else
                local nJackPotIndex = nType
                fAddMoneyCount = WitchLevelUI.tableNowJackPotMoneyCount[nJackPotIndex]
                
                if not WitchLevelUI.tableNowbGetJackPot[nJackPotIndex] then
                    WitchLevelUI.tableNowbGetJackPot[nJackPotIndex] = true
                    WitchLevelUI.mJackPotUI:ResetCurrentJackPot(nJackPotIndex)
                end
            end

            fReSpinCollectMoneyCount = fReSpinCollectMoneyCount + fAddMoneyCount

            if not self.m_nSimuReSpinAwardInfo[nType] then
                self.m_nSimuReSpinAwardInfo[nType] = {nCount = 0, nMoneyCount = 0}
            end

            self.m_nSimuReSpinAwardInfo[nType].nCount = self.m_nSimuReSpinAwardInfo[nType].nCount + 1
            self.m_nSimuReSpinAwardInfo[nType].nMoneyCount = self.m_nSimuReSpinAwardInfo[nType].nMoneyCount + 1
        end
    end

    return fReSpinCollectMoneyCount
end

function WitchFunc:SimuGetReSpinAllMoneyCount()
    if not self.m_bSimulationFlag then
        return
    end

    local rt = SlotsGameLua.m_GameResult
    if WitchFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    if LuaHelper.tableSize(WitchFunc.tableReSpinFixedCollectSymbol) == SlotsGameLua.m_nReelCount * SlotsGameLua.m_nRowCount then
        local nJackPotIndex = 4
        local fAddMoneyCount = WitchLevelUI.tableNowJackPotMoneyCount[nJackPotIndex]

        self.fReSpinCollectMoneyCount = self.fReSpinCollectMoneyCount + fAddMoneyCount
        if rt:InFreeSpin() then
            self.m_nSimuFreeSpinMoneyCount = self.m_nSimuFreeSpinMoneyCount + fAddMoneyCount
        end

        if not WitchLevelUI.tableNowbGetJackPot[nJackPotIndex] then
            WitchLevelUI.tableNowbGetJackPot[nJackPotIndex] = true
            WitchLevelUI.mJackPotUI:ResetCurrentJackPot(nJackPotIndex)
        end

        self.m_nSimuJackPotGrandCount =  self.m_nSimuJackPotGrandCount + 1
        self.m_nSimuJackPotGrandMoneyCount = self.m_nSimuJackPotGrandMoneyCount + fAddMoneyCount
    end

    rt.m_fSpinWin = rt.m_fSpinWin + self.fReSpinCollectMoneyCount
end

function WitchFunc:GetSymbolAwardMultuile(nSymbolId, nMatchCount)
    local rt = SlotsGameLua.m_GameResult
    if WitchFunc.m_bSimulationFlag then
        rt = SlotsGameLua.m_TestGameResult
    end

    local nMultuile = 0
    if rt:InFreeSpin() then
        nMultuile = WitchConfig.FREESPIN_SYMBOL_AWARD_MULTUILE[nSymbolId][nMatchCount]
    else
        nMultuile = SlotsGameLua:GetSymbol(nSymbolId).m_fRewards[nMatchCount]
    end

    return nMultuile
end

function WitchFunc:CheckSpinWinPayLines(deck, result)
    result:ResetSpin()

    if not result:InReSpin() then
        for i = 1, #SlotsGameLua.m_listLineLua do
            local iResult = {}
            local ld = SlotsGameLua:GetLine(i)
            for x = 0, SlotsGameLua.m_nReelCount - 1 do
                local nRowIndex = ld.Slots[x]
                local nKey =  x * SlotsGameLua.m_nRowCount + nRowIndex
                iResult[x] = deck[nKey]
            end

            local MatchCount = 0
            local nMaxMatchReelID = 0
            local bcond2 = false

            local bWildMatchSuccess = false
            local bIdMatchSuccess = false

            local nSymbolId = -1
            local bMatchSuccess = false
            if not bMatchSuccess then
                bMatchSuccess, nSymbolId, MatchCount, nMaxMatchReelID = self:CheckLineSymboltIdSame(iResult)
                if bMatchSuccess then
                    bIdMatchSuccess = true
        
                    --Debug.Log("ID 匹配成功")
                end
            end

            if not bMatchSuccess then
                bMatchSuccess, nSymbolId, MatchCount, nMaxMatchReelID = self:CheckLineWildMatch(iResult)
                if bMatchSuccess then
                    bWildMatchSuccess = true
                    
                    --Debug.Log("Wild 匹配成功")
                end
            end

            local fCombReward = -1
            local nCombIndex = -1

            if bWildMatchSuccess or bIdMatchSuccess then
                fCombReward = self:GetSymbolAwardMultuile(nSymbolId, MatchCount)
            end
            
            if fCombReward > 0.0 then
                self.m_nWin0Count = 0
                local nTotalBet = SceneSlotGame.m_nTotalBet
                local fLineBet = nTotalBet / 100
                local LineWin = fCombReward * fLineBet

                table.insert(result.m_listWins, WinItem:create(i, nSymbolId, MatchCount, LineWin, bcond2, nMaxMatchReelID))
                result.m_fSpinWin = result.m_fSpinWin + LineWin

                if self.m_bSimulationFlag then  
                    if result.m_listTestWinSymbols[nSymbolId] == nil then
                        result.m_listTestWinSymbols[nSymbolId] = TestWinItem:create(nSymbolId)
                    end

                    result.m_listTestWinSymbols[nSymbolId].Hit = result.m_listTestWinSymbols[nSymbolId].Hit + 1
                    result.m_listTestWinSymbols[nSymbolId].WinGold = result.m_listTestWinSymbols[nSymbolId].WinGold + LineWin
                end

                if not self.m_bSimulationFlag then
                    self:refreshHitSymbols(i, nMaxMatchReelID)
                end
            end

        end

        if not self.m_bSimulationFlag then
            WitchLevelUI:PlayNormalWildMergeAni()
        end
        
    end

    self:CheckGameResult(deck, result)
    if result:InReSpin() then
        if not result:HasReSpin() then
            self.fReSpinCollectMoneyCount = self.fReSpinCollectMoneyCount + self:GetReSpinMoneyCount(result)

            if not self.m_bSimulationFlag then
                WitchLevelUI:CollectMoneyToDB(self.fReSpinCollectMoneyCount)
                WitchFunc.bInReSpin = false
                WitchLevelUI:setDBReSpin()
            end

            if self.m_bSimulationFlag then
                self:SimuGetReSpinAllMoneyCount()

                self.m_nSimuReSpinMoneyCount = self.m_nSimuReSpinMoneyCount +  self.fReSpinCollectMoneyCount
                if result:InFreeSpin() then
                    self.m_nSimuFreeSpinReSpinMoneyCount = self.m_nSimuFreeSpinReSpinMoneyCount + self.fReSpinCollectMoneyCount
                else
                    self.m_nSimuNormalReSpinMoneyCount = self.m_nSimuNormalReSpinMoneyCount + self.fReSpinCollectMoneyCount
                end

                self.m_nSimuReSpinAverageCollectCount = self.m_nSimuReSpinAverageCollectCount + LuaHelper.tableSize(self.tableReSpinFixedCollectSymbol)
                
                if self.fReSpinCollectMoneyCount / SceneSlotGame.m_nTotalBet >= 100.0 then
                    self.m_nSimuReSpinBigMultuileCount = self.m_nSimuReSpinBigMultuileCount + 1
                    self.m_nSimuReSpinBigMultuileMoneyCount = self.m_nSimuReSpinBigMultuileMoneyCount + self.fReSpinCollectMoneyCount
                end

                self:SimulationReSpinFinish()
            end 
        end
    end

    if result:InFreeSpin() then
        result.m_fFreeSpinTotalWins = result.m_fFreeSpinTotalWins + result.m_fSpinWin

        if self.m_bSimulationFlag then
            self.m_nSimuFreeSpinMoneyCount = self.m_nSimuFreeSpinMoneyCount + result.m_fSpinWin
        end
    end 

    result.m_fGameWin = result.m_fGameWin + result.m_fSpinWin
    return result
end

--检查Wild 匹配
function WitchFunc:CheckLineWildMatch(iResult)
    local MatchCount = 0
    local nMaxMatchReelID = -1

    local nWildSymbolId = SlotsGameLua:GetSymbolIdByObjName("Wild")
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local v = iResult[i]
        if WitchSymbol:isWildSymbol(v) then
            MatchCount = MatchCount + 1
            nMaxMatchReelID = i
        else
            break
        end
    end 

    if MatchCount > 0 and self:GetSymbolAwardMultuile(nWildSymbolId, MatchCount) > 0 then
        return true, nWildSymbolId, MatchCount, nMaxMatchReelID
    else
        return false
    end

end

--检查ID 是否相同
function WitchFunc:CheckLineSymboltIdSame(iResult)
    local nSymbolId = -1
    local bFindFirstTag = false
    local MatchCount = 0
    local nMaxMatchReelID = -1

    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local v = iResult[i]
        if WitchSymbol:IsNoLineAwardSymbolId(v) then
            break
        end

        if not WitchSymbol:isWildSymbol(v) then
            if not bFindFirstTag then
                bFindFirstTag = true
                nSymbolId = v
            end
        end

        if WitchSymbol:isWildSymbol(v) or (nSymbolId > 0 and nSymbolId == v) then
            MatchCount = MatchCount + 1
            nMaxMatchReelID = i
        else
            break
        end

    end     

    if nSymbolId > 0 and MatchCount > 0 and self:GetSymbolAwardMultuile(nSymbolId, MatchCount) > 0 then
        return true, nSymbolId, MatchCount, nMaxMatchReelID
    else
        return false
    end 

end

function WitchFunc:SimulationReSpinBegin()
    WitchLevelUI.mLeveData_ReSpin:SimuActive()

    local tempTable = {}
    for k, v in pairs(self.tableReSpinFixedCollectSymbol) do
        local nKey = k
        nKey = WitchLevelUI:NormalToReSpinDeckKey(nKey)
        tempTable[nKey] = v
    end 

    self.tableReSpinFixedCollectSymbol = tempTable
end

function WitchFunc:SimulationReSpinFinish()
    WitchLevelUI.mLeveData_Normal:SimuActive()
    self:CancelAllReSpinFixedSymbol()
end

--仿真，把结果 输入到文本文件中
function WitchFunc:Simulation()
    self.m_bSimulationFlag = true
    self:GetTestResultByRate()
    self:WriteToFile()
    self.m_bSimulationFlag = false
end

function WitchFunc:GetTestResultByRate()
    local rt = SlotsGameLua.m_TestGameResult
    rt:ResetGame(true)

    local nPreTotalBet = SceneSlotGame.m_nTotalBet
    SceneSlotGame.m_nTotalBet = 1
    ReturnRateManager.m_enumReturnRateType = SlotsGameLua.m_enumSimRateType
    ChoiceCommonFunc:CreateChoice()
    local nSimulationCount = SlotsGameLua.m_SimulationCount

    local pretableJackPotAddSumMoneyCount = WitchLevelUI.mJackPotUI.tableJackPotAddSumMoneyCount
    WitchLevelUI.mJackPotUI.tableJackPotAddSumMoneyCount = {0, 0, 0, 0, 0}
    
    self.m_nSimuBigMultuileCount = 0
    self.m_nSimuBigMultuileMoneyCount = 0
    self.m_nSimuReSpinBigMultuileCount = 0
    self.m_nSimuReSpinBigMultuileMoneyCount = 0

    -- FreeSpin 相关
    self.m_nSimuFreeSpinCount = 0
    self.m_nSimuFreeSpinTriggerCount = 0 
    self.m_nSimuFreeSpinMoneyCount = 0

    -- ReSpin 相关
    self.m_nSimuReSpinCount = 0

    self.m_nSimuReSpinTriggerCount = 0
    self.m_nSimuReSpinMoneyCount = 0
    self.m_nSimuReSpinAverageCollectCount = 0

    self.m_nSimuNormalReSpinTriggerCount = 0
    self.m_nSimuNormalReSpinMoneyCount = 0
    self.m_nSimuFreeSpinReSpinTriggerCount = 0
    self.m_nSimuFreeSpinReSpinMoneyCount = 0

    self.m_nSimuReSpinAwardInfo = {}
    self.m_nSimuJackPotAwardInfo = {}

    self.m_nSimuJackPotGrandCount = 0
    self.m_nSimuJackPotGrandMoneyCount = 0

    local c = 0
    while true do
        local bFlag = rt:Spin()
        local bFreeSpinFlag = rt:HasFreeSpin()
        local bReSpinFlag = rt:HasReSpin()
        
        if c >= 2 * nSimulationCount then
            break
        end

        if c >= nSimulationCount and (not bFreeSpinFlag) and (not bReSpinFlag) then
            break
        end 

        if bReSpinFlag then
            rt.m_nReSpinCount = rt.m_nReSpinCount + 1
            self.m_nSimuReSpinCount = self.m_nSimuReSpinCount + 1
        elseif bFreeSpinFlag then
            rt.m_nFreeSpinCount = rt.m_nFreeSpinCount + 1
            self.m_nSimuFreeSpinCount = self.m_nSimuFreeSpinCount + 1
        end

        WitchLevelUI.mJackPotUI:addJackPotValue()

        local iDeck = self:GetDeck()
        rt = self:CheckSpinWinPayLines(iDeck, rt)

        if not bReSpinFlag then
            if rt.m_fSpinWin / SceneSlotGame.m_nTotalBet >= 100.0 then
                self.m_nSimuBigMultuileCount = self.m_nSimuBigMultuileCount + 1
                self.m_nSimuBigMultuileMoneyCount = self.m_nSimuBigMultuileMoneyCount + rt.m_fSpinWin
            end

            if rt.m_fSpinWin == 0.0 then
                self.m_nSimuWin0SpinNum = self.m_nSimuWin0SpinNum  + 1
            end
        end

        if not bReSpinFlag then
            c = c + 1
        end 

        Debug.Assert(SceneSlotGame.m_nTotalBet == 1)
        Debug.Assert(ReturnRateManager.m_enumReturnRateType == SlotsGameLua.m_enumSimRateType)
    end

    self.m_nSimulationCount = c
    SlotsGameLua.m_TestGameResult = rt
    SceneSlotGame.m_nTotalBet = nPreTotalBet  --下注 金额 还原
    ChoiceCommonFunc:CreateChoice()

    WitchLevelUI.mJackPotUI.tableJackPotAddSumMoneyCount = pretableJackPotAddSumMoneyCount
end 

function WitchFunc:WriteToFile()
    local strFile = ThemeLoader.themeKey .. "\n"
    local levelReturnRateType = SlotsGameLua.m_enumSimRateType
    if levelReturnRateType == enumReturnRateTYPE.enumReturnType_Rate200 then
        strFile = strFile.."=============enumReturnType_Rate200============\n"
    elseif levelReturnRateType == enumReturnRateTYPE.enumReturnType_Rate95 then
        strFile = strFile.."============enumReturnType_Rate95===============\n"
    elseif levelReturnRateType == enumReturnRateTYPE.enumReturnType_Rate50 then
        strFile = strFile.."==========enumReturnType_Rate50=============\n"
    end

    local rt = SlotsGameLua.m_TestGameResult
    local fTotalUse = 1.0 * (self.m_nSimulationCount  - self.m_nSimuFreeSpinCount)

    local fTotalWin = rt.m_fGameWin
    local Ratio = fTotalWin / fTotalUse

    strFile = strFile.."Test SimulationCount:  "..SlotsGameLua.m_SimulationCount.."\n"
    strFile = strFile.."Actual SimulationCount:  "..self.m_nSimulationCount.."\n"
    strFile = strFile.."TotalBets : "..fTotalUse.."\n"
    strFile = strFile.."TotalWins : "..fTotalWin.."\n"
    strFile = strFile.."Return Rate: "..Ratio.."\n"
    strFile = strFile .. "\n"

    strFile = strFile .. "----------------------------------" .. "\n"
    local nSymbolCount = #SlotsGameLua.m_listSymbolLua
    for i = 1, nSymbolCount do
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

    strFile = strFile .. "\n"
    strFile = strFile.."不中奖的概率: "..(self.m_nSimuWin0SpinNum / self.m_nSimulationCount).."\n"
    strFile = strFile.."正常 超过 100倍 赢钱的次数: "..self.m_nSimuBigMultuileCount.." | "..self.m_nSimuBigMultuileMoneyCount.."\n"
    strFile = strFile.."ReSpin 超过 100倍 赢钱的次数: "..self.m_nSimuReSpinBigMultuileCount.." | "..self.m_nSimuReSpinBigMultuileMoneyCount.."\n"

    strFile = strFile .. "\n"
    strFile = strFile.."FreeSpin 总次数： " .. self.m_nSimuFreeSpinCount .. "\n"
    strFile = strFile.."FreeSpin 总赢钱： " .. self.m_nSimuFreeSpinMoneyCount .. "\n"
    strFile = strFile.."FreeSpin 触发次数： " .. self.m_nSimuFreeSpinTriggerCount .. "\n"

    strFile = strFile.."FreeSpin 每次触发 平均次数： " .. (self.m_nSimuFreeSpinCount / (self.m_nSimuFreeSpinTriggerCount)) .. "\n"
    strFile = strFile .. "\n"

    strFile = strFile.."ReSpin 总次数： " .. self.m_nSimuReSpinCount .. "\n"
    strFile = strFile.."ReSpin 总触发次数： " .. self.m_nSimuReSpinTriggerCount .. "\n"
    strFile = strFile.."ReSpin 总赢钱： " .. self.m_nSimuReSpinMoneyCount .. "\n"
    strFile = strFile.."ReSpin 平均收集个数： " .. self.m_nSimuReSpinAverageCollectCount / self.m_nSimuReSpinTriggerCount .. "\n"

    strFile = strFile .. "\n"
    strFile = strFile.."非FreeSpin中 ReSpin 触发次数： " .. self.m_nSimuNormalReSpinTriggerCount .. "\n"
    strFile = strFile.."非FreeSpin中 ReSpin 总赢钱： " .. self.m_nSimuNormalReSpinMoneyCount .. "\n"
    strFile = strFile.."FreeSpin中 ReSpin 触发次数： " .. self.m_nSimuFreeSpinReSpinTriggerCount .. "\n"
    strFile = strFile.."FreeSpin中 ReSpin 总赢钱： " .. self.m_nSimuFreeSpinReSpinMoneyCount .. "\n"

    strFile = strFile .. "\n"
    for i = 1, 4 do
        local nCount = 0
        local nMoneyCount = 0
        if self.m_nSimuReSpinAwardInfo[i] then
            nCount = self.m_nSimuReSpinAwardInfo[i].nCount
            nMoneyCount = self.m_nSimuReSpinAwardInfo[i].nMoneyCount
        end

        strFile = strFile.."ReSpin 奖励 类型 : "..i.." : "..nCount.." | "..nMoneyCount.."\n"
    end

    strFile = strFile.."JackPot Grands : "..self.m_nSimuJackPotGrandCount.." | ".. self.m_nSimuJackPotGrandMoneyCount.."\n"

    strFile = strFile .. "\n"
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

---------------------------------------------------------------------------------------
function WitchFunc:initSlotsGameParam()
    SlotsGameLua:setCreateReelRandomSymbolListFunc(self, self.CreateReelRandomSymbolList)
    SlotsGameLua:setGetDeckFunc(self, self.GetDeck)
    SlotsGameLua:setPreCheckWinFunc(self, self.PreCheckWin)
    SlotsGameLua:setCheckSpinWinPayLinesFunc(self, self.CheckSpinWinPayLines)
    SlotsGameLua:setSimulationFunc(self, self.Simulation)

    SlotsGameLua:setOnStartSpinFunc(self, self.OnStartSpin)
    SlotsGameLua:setOnSpinEndFunc(self, self.OnSpinEnd)

    SceneSlotGame.m_LevelUiTableParam = WitchLevelUI
end
