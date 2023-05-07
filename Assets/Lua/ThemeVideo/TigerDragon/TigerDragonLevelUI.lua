TigerDragonLevelUI = {}

function TigerDragonLevelUI:InitVariable()
    self.m_LeanTweenIDs = {}
    self.m_transform = nil

    self.m_RegisterLoadEffectNameTable = {"lztukuai", "OpenTigerDragonDoorEffect"}
    self.tableFixedGoSymbol = {}
end 

function TigerDragonLevelUI:initLevelUI()
    self:InitVariable()
    TigerDragonFunc:InitVariable()

    self.m_transform = ThemeVideoScene.mNewGameNodeParent:FindDeepChild("LevelBG")
    LuaAutoBindMonoBehaviour.Bind(self.m_transform.gameObject, self)

    self.mFreeSpinBeginSplashUI = require "Lua/ThemeVideo/TigerDragon/FreeSpinBeginSplashUI"
    self.mFreeSpinBeginSplashUI:Init()

    self.mFreeSpinAgainSplashUI = require "Lua/ThemeVideo/TigerDragon/FreeSpinAgainSplashUI"
    self.mFreeSpinAgainSplashUI:Init()

    self.mFreeSpinFinishSplashUI = require "Lua/ThemeVideo/TigerDragon/FreeSpinFinishSplashUI"
    self.mFreeSpinFinishSplashUI:Init()
    
    self.mDeckResultPayWays = require "Lua/ThemeVideo/TigerDragon/DeckResultPayWays"
    self.mDeckResultPayWays:Init(SlotsGameLua)

end     

function TigerDragonLevelUI:Update()
    self.mDeckResultPayWays:DisplayMatchWaysInfo()
    self.mDeckResultPayWays:DisplayAllMatchWaysInfo()
end 

function TigerDragonLevelUI:OnDestroy()
    self:CancelLeanTween()
    LuaHelper.ReleaseVariable(self)
    LuaHelper.ReleaseVariable(TigerDragonFunc)
end

function TigerDragonLevelUI:CancelLeanTween()
	local count = #self.m_LeanTweenIDs
	for i=1, count do
		local id = self.m_LeanTweenIDs[i]
		if LeanTween.isTweening(id) then
			LeanTween.cancel(id)
		end
	end
	self.m_LeanTweenIDs = {}
end

function TigerDragonLevelUI:SetInteger(mAnimator, strKey, nAction)
    if mAnimator.gameObject.activeInHierarchy then
        if mAnimator:GetInteger(strKey) ~= nAction then
            mAnimator:SetInteger(strKey, nAction)
        end
    end
end

-- 查找某个符号的子节点，并缓存下来，高效可靠
function TigerDragonLevelUI:FindSymbolElement(goSymbol, strKey)
    local tablePoolKey = {"gem1", "gem2", "gem3", "TextMeshPro", "GrandClickEffect", "MajorClickEffect", "MinorClickEffect"}
    
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
            else
                self.goSymbolElementPool[goSymbol][strKey] = go
            end
        end
    end 

    return self.goSymbolElementPool[goSymbol][strKey]
end

function TigerDragonLevelUI:OnPreReelStop(nReelId)
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
            if TigerDragonSymbol:isScatterSymbol(nSymbolId) then
                local goSymbol = reel.m_listGoSymbol[i]
                
                LeanTween.scale(goSymbol, Unity.Vector3.one * 1.2, 0.15):setLoopPingPong(1)

                if not SpinButton.m_bUserStopSpin then
                    AudioHandler:PlayScatterStopSound(nReelId)
                elseif not TigerDragonFunc.m_bScatterSound then
                    AudioHandler:PlayScatterStopSound(nReelId)
                    TigerDragonFunc.m_bScatterSound = true
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

function TigerDragonLevelUI:isScatterPossibleUseful(nReelId)
    local nScatterCount = 0
    for x = 0, nReelId - 1 do
        local reel = SlotsGameLua.m_listReelLua[x]
        for i = 0, SlotsGameLua.m_nRowCount - 1 do
            local nSymbolId = reel.m_curSymbolIds[i]
            local nKey = x * SlotsGameLua.m_nRowCount + i
            if TigerDragonFunc:orValidKey(nKey) then
                if TigerDragonSymbol:isScatterSymbol(nSymbolId) then
                    nScatterCount = nScatterCount + 1
                    break
                end
            end
        end
    end       
    
    if nReelId == 0 then
        return true
    elseif nReelId == 2 then
        return nScatterCount >= 1 
    elseif nReelId == 4 then
        return nScatterCount >= 2
    end
end

function TigerDragonLevelUI:isNeedWaitingFreeSpin(nReelId)
    if nReelId >= SlotsGameLua.m_nReelCount - 1 then
        return false
    end         

    local nScatterCount = 0
    for x = 0, nReelId do
        local reel = SlotsGameLua.m_listReelLua[x]
        for i = 0, SlotsGameLua.m_nRowCount - 1 do
            local nSymbolId = reel.m_curSymbolIds[i]
            local nKey = x * SlotsGameLua.m_nRowCount + i
            if TigerDragonFunc:orValidKey(nKey) then
                if TigerDragonSymbol:isScatterSymbol(nSymbolId) then
                    nScatterCount = nScatterCount + 1
                    break
                end
            end
        end
    end

    return nReelId == 3 and nScatterCount >= 2
end

function TigerDragonLevelUI:CheckRecoverInfo()
    self.tableCachePos = {}
    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        for j = 0, SlotsGameLua.m_nRowCount * 2 - 1 do
            local nKey = i * SlotsGameLua.m_nRowCount + j
            local goSymbol = SlotsGameLua.m_listReelLua[i].m_listGoSymbol[j]
            self.tableCachePos[nKey] = goSymbol.transform.position
        end
    end

    for i = 0, SlotsGameLua.m_nReelCount - 1 do
        local reelLua = SlotsGameLua.m_listReelLua[i]
        local fPosX = (i - 2) * SlotsGameLua.m_fSymbolWidth
        reelLua.m_transform.localPosition = Unity.Vector3(fPosX, 0, 0)
    end

end

-- 显示Scatter 特效 -- 统一使用播放spine动画的接口: PlayActiveAnimation(enumType, true, 1.0)
function TigerDragonLevelUI:ShowScatterBonusEffect()
    self.tableCollectScatter = {}
        
    for x = 0, SlotsGameLua.m_nReelCount - 1 do
        for y = 0, SlotsGameLua.m_nRowCount - 1 do
            local nKey = x * SlotsGameLua.m_nRowCount + y
            local reel = SlotsGameLua.m_listReelLua[x]

            local nSymbolId = reel.m_curSymbolIds[y]
            if TigerDragonSymbol:isScatterSymbol(nSymbolId) then
                local goSymbol = reel.m_listGoSymbol[y]
                self.tableCollectScatter[nKey] = goSymbol
            end
        end
    end                  

    for k, v in pairs(self.tableCollectScatter) do
        SymbolObjectPool.m_mapSpinEffect[v]:PlayAnimation("animation", 0.0, true)
    end

end 

function TigerDragonLevelUI:handleFreeSpinBegin()
    self.mDeckResultPayWays:MatchLineHide()

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

function TigerDragonLevelUI:handleFreeSpinEnd()
    self.mDeckResultPayWays:MatchLineHide()
    self.mFreeSpinFinishSplashUI:Show()
end

function TigerDragonLevelUI:FillSymbol(nSymbolId, nReelId, nRowIndex)
    local preGoSymbol = SlotsGameLua.m_listReelLua[nReelId].m_listGoSymbol[nRowIndex]
    if preGoSymbol then
        SymbolObjectPool:Unspawn(preGoSymbol)
    end

    local newGO = LevelCommonFunctions:SpawnSymbol(nSymbolId, nReelId, nRowIndex)
    newGO.transform:SetParent(SlotsGameLua.m_listReelLua[nReelId].m_transform, false)
    newGO.transform.localScale = Unity.Vector3.one
    newGO.transform.localPosition = SlotsGameLua.m_listReelLua[nReelId].m_listSymbolPos[nRowIndex]

    SlotsGameLua.m_listReelLua[nReelId].m_listGoSymbol[nRowIndex] = newGO
    SlotsGameLua.m_listReelLua[nReelId].m_curSymbolIds[nRowIndex] = nSymbolId
    return newGO
end

function TigerDragonLevelUI:FixedSymbol(nSymbolId, nReelId, nRowIndex)
    local nKey = nReelId * SlotsGameLua.m_nRowCount + nRowIndex
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

function TigerDragonLevelUI:ResetTotalWinToUI(fMoneyCount)
    SlotsGameLua.m_GameResult.m_fGameWin = fMoneyCount
    SceneSlotGame.m_SlotsNumberWins:End(fMoneyCount)
end

function TigerDragonLevelUI:UpdateTotalWinToUI(fAddMoneyCount, fAniTime)
    if fAniTime == nil then
        fAniTime = 1.0
    end

    SlotsGameLua.m_GameResult.m_fGameWin = SlotsGameLua.m_GameResult.m_fGameWin + fAddMoneyCount
    SceneSlotGame.m_fCurWinCoinTime = fAniTime
    SceneSlotGame:UpdateTotalWinToUI()
end

function TigerDragonLevelUI:CollectMoneyToDB(fAddMoneyCount)
    if SlotsGameLua.m_GameResult:InFreeSpin() then
        SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins = SlotsGameLua.m_GameResult.m_fFreeSpinTotalWins + fAddMoneyCount
        LevelDataHandler:addFreeSpinTotalWin(ThemeLoader.themeKey, fAddMoneyCount)
    else
        PlayerHandler:AddCoin(fAddMoneyCount)
        LevelDataHandler:AddPlayerWinCoins(fAddMoneyCount)
    end
end

---------------------- 设置 符号 的层级 -----------------------------
function TigerDragonLevelUI:CacheSymbolElementLayer(goSymbol)
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

function TigerDragonLevelUI:SetModifyLayer(goSymbol, nOrder)
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

function TigerDragonLevelUI:SetDefaultLayer(goSymbol)
    self:CacheSymbolElementLayer(goSymbol)
    local elementTable = self.mapGoSortingOrder[goSymbol]
    for k, v in pairs(elementTable) do
        k.sortingOrder = v
    end
end

--=--------------------------- Simple Effect Pool -----------------------------------

function TigerDragonLevelUI:GetEffectByEffectPool(strKey)
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

function TigerDragonLevelUI:RecycleEffectToEffectPool(UsedObj)
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
