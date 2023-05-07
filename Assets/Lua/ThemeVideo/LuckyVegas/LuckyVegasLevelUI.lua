LuckyVegasLevelUI = {}

function LuckyVegasLevelUI:InitVariable()
    self.m_LeanTweenIDs = {}
    self.m_transform = nil

    self.m_RegisterLoadEffectNameTable = {"gem1CollectEffect", "gem2CollectEffect", "gem3CollectEffect"}
    self.tableFixedGoSymbol = {}
end 

function LuckyVegasLevelUI:initLevelUI()
    self:InitVariable()
    LuckyVegasFunc:InitVariable()
    
    self.m_transform = ThemeVideoScene.mNewGameNodeParent:FindDeepChild("LevelBG")
    LuaAutoBindMonoBehaviour.Bind(self.m_transform.gameObject, self)

    self.mJackPotUI = require("Lua/ThemeVideo/LuckyVegas/JackPotUI")
    self.mJackPotUI:Init()

    self.mFreeSpinBeginSplashUI = require("Lua/ThemeVideo/LuckyVegas/FreeSpinBeginSplashUI")
    self.mFreeSpinBeginSplashUI:Init()

    self.mFreeSpinAgainSplashUI = require("Lua/ThemeVideo/LuckyVegas/FreeSpinAgainSplashUI")
    self.mFreeSpinAgainSplashUI:Init()

    self.mFreeSpinFinishSplashUI = require("Lua/ThemeVideo/LuckyVegas/FreeSpinFinishSplashUI")
    self.mFreeSpinFinishSplashUI:Init()
end     

function LuckyVegasLevelUI:Update()
    self.mJackPotUI:Update()
end 

function LuckyVegasLevelUI:OnDestroy()
    self:CancelLeanTween()
    LuaHelper.ReleaseVariable(self)
    LuaHelper.ReleaseVariable(LuckyVegasFunc)
end

function LuckyVegasLevelUI:CancelLeanTween()
	local count = #self.m_LeanTweenIDs
	for i=1, count do
		local id = self.m_LeanTweenIDs[i]
		if LeanTween.isTweening(id) then
			LeanTween.cancel(id)
		end
	end
	self.m_LeanTweenIDs = {}
end

function LuckyVegasLevelUI:SetInteger(mAnimator, strKey, nAction)
    if mAnimator.gameObject.activeInHierarchy then
        if mAnimator:GetInteger(strKey) ~= nAction then
            mAnimator:SetInteger(strKey, nAction)
        end
    end
end

-- 查找某个符号的子节点，并缓存下来，高效可靠
function LuckyVegasLevelUI:FindSymbolElement(goSymbol, strKey)
    local tablePoolKey = {"ANI1", "ANI2"}

    Debug.Assert(LuaHelper.tableContainsElement(tablePoolKey, strKey))

    if self.goSymbolElementPool == nil then
        self.goSymbolElementPool = {}
    end 

    if self.goSymbolElementPool[goSymbol] == nil then
        self.goSymbolElementPool[goSymbol] = {}
    end 

    if self.goSymbolElementPool[goSymbol][strKey] == nil then
        local goTran = goSymbol.transform:FindDeepChild(strKey)
        if goTran then
            local go = goTran.gameObject

            if strKey == "TextMeshPro" then 
                self.goSymbolElementPool[goSymbol][strKey] = go:GetComponent(typeof(TextMeshPro))
            elseif strKey == "ANI1" or strKey == "ANI2" then 
                self.goSymbolElementPool[goSymbol][strKey] = go:GetComponent(typeof(Unity.Animator))
            else
                self.goSymbolElementPool[goSymbol][strKey] = go
            end
        end
    end 

    return self.goSymbolElementPool[goSymbol][strKey]
end

function LuckyVegasLevelUI:OnPreReelStop(nReelId)
    local reel = SlotsGameLua.m_listReelLua[nReelId]

    local bHaveBonus = false
    for i = 0, SlotsGameLua.m_nRowCount - 1 do
        local nSymbolId = reel.m_curSymbolIds[i]
        local goSymbol = reel.m_listGoSymbol[i]

    end

    local bAllReelFixedSymbol = true
    for i = 0, SlotsGameLua.m_nRowCount - 1 do
        local bStickyFlag, nStickyIndex = reel:isStickyPos(i)
        if not bStickyFlag then
            bAllReelFixedSymbol = false
            break
        end
    end 

    if SpinButton.m_bUserStopSpin then
        AudioHandler:StopSlotsOnFire()
        if reel.m_ScatterEffectObj ~= nil then -- 这列都停了，如果上一列有着火特效也马上停掉。。（绕着列转大圈圈的特效）
            reel.m_ScatterEffectObj:reuseCacheEffect()
            reel.m_ScatterEffectObj = nil
        end
    end 

    --播放 列停止声音
    if not SpinButton.m_bUserStopSpin then
        if not LevelCommonFunctions:isStopReel(nReelId) and not bAllReelFixedSymbol then
            AudioHandler:PlayReelStopSound(nReelId)
        end
    elseif nReelId == SlotsGameLua.m_nReelCount - 1 then
        AudioHandler:PlayReelStopSound(nReelId)
    end

    --scatter 列停止动画
    if self:isScatterPossibleUseful(nReelId) then
        for i = 0, SlotsGameLua.m_nRowCount - 1 do
            local nSymbolId = reel.m_curSymbolIds[i]
            if LuckyVegasSymbol:isScatterSymbol(nSymbolId) then
                local goSymbol = reel.m_listGoSymbol[i]

                LeanTween.scale(goSymbol, Unity.Vector3.one * 1.2, 0.15):setLoopPingPong(1)

                self:SetModifyLayer(goSymbol, 20)
                LeanTween.delayedCall(1.0, function()
                    self:SetModifyLayer(goSymbol, -24)
                end)

                if not SpinButton.m_bUserStopSpin then
                    AudioHandler:PlayScatterStopSound(nReelId)
                elseif not LuckyVegasFunc.m_bScatterSound then
                    AudioHandler:PlayScatterStopSound(nReelId)
                    LuckyVegasFunc.m_bScatterSound = true
                end
            end
        end
    end

    local bPlayingSlotFireSound = false
    --Scatter 着火开始
    if self:isNeedWaitingFreeSpin(nReelId) and not SpinButton.m_bUserStopSpin then
        reel:PlayEffectWaitingFreeSpin()
        bPlayingSlotFireSound = true
    else
        SlotsGameLua.m_bPlayingSlotFireSound = false
        AudioHandler:StopSlotsOnFire()
    end
    
    if reel.m_ScatterEffectObj ~= nil then -- 这列都停了，如果上一列有着火特效也马上停掉。。（绕着列转大圈圈的特效）
        reel.m_ScatterEffectObj:reuseCacheEffect()
        reel.m_ScatterEffectObj = nil
    end
end

function LuckyVegasLevelUI:isScatterPossibleUseful(nReelId)
    local nScatterCount = 0
    for x = 0, nReelId - 1 do
        local reel = SlotsGameLua.m_listReelLua[x]
        for i = 0, SlotsGameLua.m_nRowCount - 1 do
            local nSymbolId = reel.m_curSymbolIds[i]

            if LuckyVegasSymbol:isScatterSymbol(nSymbolId) then
                nScatterCount = nScatterCount + 1
                break
            end
        end
    end     

    if SlotsGameLua.m_GameResult:InFreeSpin() then
        return nScatterCount + SlotsGameLua.m_nReelCount - nReelId >= 2
    else
        return nScatterCount + SlotsGameLua.m_nReelCount - nReelId >= 3
    end
end

function LuckyVegasLevelUI:isNeedWaitingFreeSpin(nReelId)
    if SlotsGameLua.m_GameResult:InFreeSpin() then
        if nReelId >= SlotsGameLua.m_nReelCount - 2 then
            return false
        end
    else
        if nReelId >= SlotsGameLua.m_nReelCount - 1 then
            return false
        end 
    end    
    
    local nScatterCount = 0
    for x = 0, nReelId do
        local reel = SlotsGameLua.m_listReelLua[x]
        for i = 0, SlotsGameLua.m_nRowCount - 1 do
            local nSymbolId = reel.m_curSymbolIds[i]

            if LuckyVegasSymbol:isScatterSymbol(nSymbolId) then
                nScatterCount = nScatterCount + 1
                break
            end
        end
    end

    if SlotsGameLua.m_GameResult:InFreeSpin() then
        return nScatterCount >= 1
    else
        return nScatterCount >= 2
    end
end

function LuckyVegasLevelUI:CheckRecoverInfo()
    self.mJackPotSplashUI = require("Lua/ThemeVideo/LuckyVegas/JackPotSplashUI")
    self.mJackPotSplashUI:Init()

    self.tableGoJackPotEffect = {}
    for i = 1, 10 do
        local name = SlotsGameLua:GetSymbol(i).prfab.name
        self.tableGoJackPotEffect[i] = self.m_transform:FindDeepChild("JackpotEffectsDir/"..name).gameObject
    end

    self.tableCachePos = {}
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount * 2 - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            local goSymbol = SlotsGameLua.m_listReelLua[i].m_listGoSymbol[j]
            self.tableCachePos[nKey] = goSymbol.transform.position
        end
    end

    if SlotsGameLua.m_GameResult:InFreeSpin() then
        LuckyVegasLevelUI:PlayFreeSpinBeginHideAni()
    end
end

-- 显示Scatter 特效 -- 统一使用播放spine动画的接口: PlayActiveAnimation(enumType, true, 1.0)
function LuckyVegasLevelUI:ShowScatterBonusEffect()
    self.tableCollectScatter = {}

    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        for y = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = x * SlotsGameLua.m_nRowCount + y
            local reel = SlotsGameLua.m_listReelLua[x]

            local nSymbolId = reel.m_curSymbolIds[y]
            if LuckyVegasSymbol:isScatterSymbol(nSymbolId) then
                local goSymbol = reel.m_listGoSymbol[y]
                self.tableCollectScatter[nKey] = goSymbol
            end
        end
    end                  

    for k, v in pairs(self.tableCollectScatter) do
        SymbolObjectPool.m_mapMultiClipEffect[v]:playAniByPlayMode(1)
    end
end

function LuckyVegasLevelUI:handleFreeSpinBegin()
    PayLinePayWaysEffectHandler:MatchLineHide()

    local bDelayTime = 0.5
    local bPlayScatterAniTime = 1.35 * 2
    LeanTween.delayedCall(bDelayTime, function()
        self:ShowScatterBonusEffect()

        if SlotsGameLua.m_GameResult.m_nFreeSpinCount == 0  then
            AudioHandler:PlayFreeGameTriggeredSound()
        else
            AudioHandler:PlayRetriggerSound()
        end

        LeanTween.delayedCall(bPlayScatterAniTime, function()
            if SlotsGameLua.m_GameResult.m_nFreeSpinCount == 0  then
                self.mFreeSpinBeginSplashUI:Show()
            else
                self.mFreeSpinAgainSplashUI:Show() 
            end
        end)
    end)

end 

function LuckyVegasLevelUI:handleFreeSpinEnd()
    PayLinePayWaysEffectHandler:MatchLineHide()
    self.mFreeSpinFinishSplashUI:Show()
end

function LuckyVegasLevelUI:ShowCustomBigMoneySplash()
    self.mJackPotUI:modifyJackpotValueByTotalBet()
    
    LeanTween.delayedCall(2.0, function()
        for k, v in pairs(LuckyVegasFunc.tableFiveOfKindSymbolId) do
            local nSymbolId = v
            if LuckyVegasFunc:orHaveJackPot(nSymbolId) then 
                local nJackPotIndex = nSymbolId

                local goAni1 = LuckyVegasLevelUI:FindSymbolElement(LuckyVegasLevelUI.tableGoJackPotEffect[nJackPotIndex], "ANI1")
                local goAni2 = LuckyVegasLevelUI:FindSymbolElement(LuckyVegasLevelUI.tableGoJackPotEffect[nJackPotIndex], "ANI2")
                goAni1.gameObject:SetActive(false)
                goAni2.gameObject:SetActive(false)

                goAni2.gameObject:SetActive(true)
            end
        end

        self.mJackPotSplashUI:Show()
    end)
end

function LuckyVegasLevelUI:PlayFreeSpinBeginHideAni()
    local nWildSymbolId = SlotsGameLua:GetSymbolIdByObjName("wild")
    for i = 0, SlotsGameLua.m_nRowCount - 1 do
        local nReelId = 4
        self:FillSymbol(nWildSymbolId, nReelId, i)
    end
end

function LuckyVegasLevelUI:FillSymbol(nSymbolId, nReelId, nRowIndex)
    local preGoSymbol = SlotsGameLua.m_listReelLua[nReelId].m_listGoSymbol[nRowIndex]
    SymbolObjectPool:Unspawn(preGoSymbol)

    local newGO = LevelCommonFunctions:SpawnSymbol(nSymbolId, nReelId, nRowIndex)
    newGO.transform:SetParent(SlotsGameLua.m_listReelLua[nReelId].m_transform, false)
    newGO.transform.localScale = Unity.Vector3.one
    newGO.transform.localPosition = SlotsGameLua.m_listReelLua[nReelId].m_listSymbolPos[nRowIndex]

    SlotsGameLua.m_listReelLua[nReelId].m_listGoSymbol[nRowIndex] = newGO
    SlotsGameLua.m_listReelLua[nReelId].m_curSymbolIds[nRowIndex] = nSymbolId
    return newGO
end

function LuckyVegasLevelUI:FixedAliceSymbol(nSymbolId, nReelId, nRowIndex)
    local nKey = nReelId * SlotsGameLua.m_nRowCount + nRowIndex
    if nRowIndex >= SlotsGameLua.m_nRowCount then
        nKey = nKey + 100
    end

    if self.tableFixedGoSymbol[nKey] then
        return
    end

    local goFixedAliceSymbol = LevelCommonFunctions:SpawnSymbol(nSymbolId, nReelId, nRowIndex)
    local newSymbolParent = SlotsGameLua.m_transform
    goFixedAliceSymbol.transform:SetParent(newSymbolParent, false)
    goFixedAliceSymbol.transform.position = SlotsGameLua.m_listReelLua[nReelId].m_listGoSymbol[nRowIndex].transform.position

    self:SetModifyLayer(goFixedAliceSymbol, 0)
    self.tableFixedGoSymbol[nKey] = goFixedAliceSymbol
    return goFixedAliceSymbol
end

function LuckyVegasLevelUI:ResetTotalWinToUI(fMoneyCount)
    SlotsGameLua.m_GameResult.m_fGameWin = fMoneyCount
    SceneSlotGame.m_SlotsNumberWins:End(fMoneyCount)
end

function LuckyVegasLevelUI:UpdateTotalWinToUI(fAddMoneyCount, fAniTime)
    if fAniTime == nil then
        fAniTime = 1.0
    end

    SlotsGameLua.m_GameResult.m_fGameWin = SlotsGameLua.m_GameResult.m_fGameWin + fAddMoneyCount
    SceneSlotGame.m_fCurWinCoinTime = fAniTime
    SceneSlotGame:UpdateTotalWinToUI()
end

function LuckyVegasLevelUI:CollectMoneyToDB(fAddMoneyCount)
    if SlotsGameLua.m_GameResult:InFreeSpin() then
        SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins = SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins + fAddMoneyCount
        LevelDataHandler:addFreeSpinTotalWin(ThemeLoader.themeKey, fAddMoneyCount)
    else
        PlayerHandler:AddCoin(fAddMoneyCount)
        LevelDataHandler:AddPlayerWinCoins(fAddMoneyCount)
    end
end

---------------------- 设置 符号 的层级 -----------------------------
function LuckyVegasLevelUI:CacheSymbolElementLayer(goSymbol)
    if not self.mapGoSortingOrder then
        self.mapGoSortingOrder = {}
    end

    if not self.mapGoSortingOrder[goSymbol] then
        self.mapGoSortingOrder[goSymbol] = {}
    end

    if not self.mapGoNeedGetOrder then
        self.mapGoNeedGetOrder = {}
    end

    if not self.mapGoNeedGetOrder[goSymbol] then
        local curveItemList = LuaHelper.GetComponentsInChildren(goSymbol, typeof(Unity.Renderer))
        self.mapGoNeedGetOrder[goSymbol] = curveItemList
    end

    if LuaHelper.tableSize(self.mapGoNeedGetOrder[goSymbol]) > 0 then
        local tableAdd = {}
        for k, v in pairs(self.mapGoNeedGetOrder[goSymbol]) do
            if v.gameObject.activeInHierarchy then
                tableAdd[k] = v
            end
        end

        for k, v in pairs(tableAdd) do
            self.mapGoSortingOrder[goSymbol][v] = v.sortingOrder
            self.mapGoNeedGetOrder[goSymbol][k] = nil
        end 

        --Debug.Log("Cache Symbol "..goSymbol.name.." : "..LuaHelper.tableSize(self.mapGoNeedGetOrder[goSymbol]))
    end

end

function LuckyVegasLevelUI:SetModifyLayer(goSymbol, nOrder)
    self:CacheSymbolElementLayer(goSymbol)

    local nMinOrder = 100000000
    local elementTable = self.mapGoSortingOrder[goSymbol]
    for k, v in pairs(elementTable) do
        if v < nMinOrder then
            nMinOrder = v
        end
    end

    local elementTable = self.mapGoSortingOrder[goSymbol]
    for k, v in pairs(elementTable) do
        k.sortingOrder = v - nMinOrder + nOrder
    end
end 

--=--------------------------- Simple Effect Pool -----------------------------------

function LuckyVegasLevelUI:GetEffectByEffectPool(strKey)
    Debug.Assert(LuaHelper.tableContainsElement(self.m_RegisterLoadEffectNameTable, strKey), strKey)

    if not self.EffectPool then
        self.EffectPool = {}
    end

    if not self.EffectPool[strKey] then
        self.EffectPool[strKey] = {}
    end

    local UsedObj =  table.remove(self.EffectPool[strKey])
    if UsedObj then
        return UsedObj
    else
        local assetPath = "SpecialEffectAnimation/"..strKey..".prefab"
        local goPrefab = AssetBundleHandler:LoadThemeAsset(assetPath, typeof(Unity.GameObject))

        for i = 1, 2 do
            local obj = Unity.Object.Instantiate(goPrefab)
            obj.transform:SetParent(self.m_transform, false)
            obj:SetActive(false)

            table.insert(self.EffectPool[strKey], obj)
        end
        
        return self:GetEffectByEffectPool(strKey)
    end
end	

function LuckyVegasLevelUI:RecycleEffectToEffectPool(UsedObj)
    UsedObj.transform:SetParent(self.m_transform, false)
    UsedObj:SetActive(false)
    local assetNameTable = self.m_RegisterLoadEffectNameTable
    for k, v in pairs(assetNameTable) do
        if string.match(UsedObj.name, v) then
            table.insert(self.EffectPool[v], UsedObj)
            return 
        end
    end

    Debug.Assert(false, "RecycleEffectToEffectPool Error: "..UsedObj.name)
end
